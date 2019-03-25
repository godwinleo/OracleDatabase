accept inc_id number prompt 'Incident ID : '

DECLARE

p_event_obj em_event_obj;
p_inc_obj em_incident_obj;
p_pblm_obj em_problem_obj;

current_event_seq_id RAW(16);

p_n1 NUMBER;
p_n2 NUMBER;
p_n3 NUMBER;
current_incident_id NUMBER := &inc_id ;


PROCEDURE populate_inc_rule_owners_on_ev
  (p_event_obj    IN em_event_obj, 
   p_incident_obj IN OUT NOCOPY em_incident_obj)
IS
  l_ev_rule_owner_with_priv MGMT_MEDIUM_STRING_ARRAY;
  l_inc_rule_owner MGMT_MEDIUM_STRING_ARRAY;
  l_ev_rule_owner MGMT_MEDIUM_STRING_ARRAY;
  l_inc_rule_only_owner MGMT_MEDIUM_STRING_ARRAY;
  l_inc_rule_owner_with_priv MGMT_MEDIUM_STRING_ARRAY;
  l_inc_rule_only_owner_priv MGMT_MEDIUM_STRING_ARRAY;
  l_der_src_obj_array DERIVED_SRC_OBJ_ARRAY := DERIVED_SRC_OBJ_ARRAY();
  l_short_circuit BOOLEAN;
BEGIN
  -- if this is a single target+src object combination based incident
  -- whether its one event or multi-event based - the privs
  -- on the incident are same as what the user has on any of the events
  IF (p_incident_obj.source_info_array.count = 1)
  THEN
    --inherit event rule owners priv to inc, if it's 1 evt to 1 inc case
    --this is the list of event rule owners which have privilege
    l_ev_rule_owner_with_priv := p_event_obj.rule_owners_priv ;
    -- we get the list of incident rule owners
    em_incident_rules.get_incident_rule_owners(p_incident_obj    => p_incident_obj,
                                               p_skip_rule_proc  => l_short_circuit,
                                               p_rule_owner_priv => l_inc_rule_owner
                                              );
    -- we get the list of event rule owners
    em_incident_rules.get_event_rule_owners(p_event_obj    => p_event_obj,
                                            p_skip_rule_proc  => l_short_circuit,
                                            p_rule_owner_priv => l_ev_rule_owner
                                           );

    -- We have already checked these rule owners for the event and determined which of
    -- them have privileges. So there is no point in rechecking the list - since the
    -- result will be the same. We can simply reuse l_ev_rule_owner_with_priv
    -- The below gets the exclusive set for incident rule owner only minusing the event rule owners
    SELECT column_value
      BULK COLLECT INTO l_inc_rule_only_owner
      FROM (SELECT column_value
              FROM TABLE(CAST(l_inc_rule_owner as mgmt_medium_string_array)) 
             MINUS
            SELECT column_value
              FROM TABLE(CAST(l_ev_rule_owner as mgmt_medium_string_array)) 
           );

    l_der_src_obj_array.extend(1);
    IF p_event_obj.source_obj.type = EM_EVENT_UTIL.SOURCE_TYPE_TARGET OR
       p_event_obj.source_obj.type = EM_EVENT_UTIL.SOURCE_TYPE_TARGET_COMPONENT
    THEN
      -- this is ok even with target components - since
      -- we don't want any privilege checking based on target components
      l_der_src_obj_array(1) :=
            new DERIVED_SRC_OBJ_INFO(p_event_obj.target_guid, null, null);
    ELSE
      l_der_src_obj_array(1) :=
            new DERIVED_SRC_OBJ_INFO(p_event_obj.target_guid, 
                                     p_event_obj.source_obj.type,
                                     p_event_obj.source_obj.id);
    END IF;

    -- check privilege for this exclusive incident rule owner set
    -- since it's single event incident, we can check priv based on event object
    l_inc_rule_only_owner_priv := EM_USER_MODEL.filter_users_by_priv(
         p_event_obj.event_seq_id, 'MANAGE_EVENT', l_inc_rule_only_owner,
         l_der_src_obj_array) ;
     
    -- 
    -- once we get the priv list incident rule list, simply combine with the 
    -- event priv list and we are good to go.
    -- Ideally we could filter out the event priv list for owner who does not 
    -- own any incient rule, but don't see much benefit doing that.
    -- 
    SELECT column_value
      BULK COLLECT INTO l_inc_rule_owner_with_priv
      FROM (SELECT column_value
              FROM TABLE(CAST(l_inc_rule_only_owner_priv as mgmt_medium_string_array)) 
             UNION ALL
            SELECT column_value
              FROM TABLE(CAST(l_ev_rule_owner as mgmt_medium_string_array)) 
           );
   
    -- if there is an owner - always add to the list
    IF p_incident_obj.owner <> EM_EVENT_UTIL.SYSTEM_DFLT_USER
    THEN
      IF l_inc_rule_owner_with_priv IS NULL
      THEN
        l_inc_rule_owner_with_priv := mgmt_medium_string_array(); 
      END IF;
      l_inc_rule_owner_with_priv.extend(1);
      l_inc_rule_owner_with_priv(l_inc_rule_owner_with_priv.COUNT) := p_incident_obj.owner;
    END IF;
    p_incident_obj.rule_owners_priv := l_inc_rule_owner_with_priv;
  ELSE
    --get rule owners for inc, if this is a multi source incident
    EM_EVENT_MANAGER.populate_rule_owners_with_priv(p_incident_obj);
  END IF ;
END populate_inc_rule_owners_on_ev ;




PROCEDURE get_event_data_for_update
  (p_event_seq_id           IN RAW,
   p_midtier_rule_timestamp IN DATE,
   p_event_obj              IN OUT em_event_obj)
IS
l_event_rec em_eventsseq_latest%ROWTYPE;
BEGIN
  EM_INCIDENT_RULES.update_midtier_rule_timestamp(p_midtier_rule_timestamp);
  EM_EVENT_MANAGER.get_event_details(
      p_event_seq_id  => p_event_seq_id,
      p_event_obj     => p_event_obj,
      p_event_rec     => l_event_rec);
  -- populate rule owners with priv
  IF p_event_obj IS NOT NULL
  THEN
    EM_EVENT_MANAGER.populate_rule_owners_with_priv(p_event_obj);
  END IF ;

END get_event_data_for_update;


PROCEDURE clear_stateless_event
  (p_event_seq_id IN RAW,
   p_midtier_rule_timestamp IN DATE)
IS
l_curr_max_severity NUMBER(2) ;
l_curr_evt_severity NUMBER(2) ;
l_inc_rec em_incidents%ROWTYPE;
BEGIN
  IF EMDW_LOG.P_IS_INFO_SET
  THEN
    EMDW_LOG.INFO('clear_stateless_event:Enter', 'CLEAR') ;
  END IF ;
  -- we get the current event detail (warning / critical) 
  -- and change the object to clear below
  get_event_data_for_update(
      p_event_seq_id => p_event_seq_id,
      p_midtier_rule_timestamp => p_midtier_rule_timestamp,
      p_event_obj => p_event_obj) ;

  -- keep track of current severity, prior to being set to clear
  -- so that its incident severity could be adjusted too based on this
  l_curr_evt_severity := p_event_obj.severity;

  p_event_obj.processing_status := EM_EVENT_UTIL.SEQ_UPDATE ; -- event update
  p_event_obj.change_attr_list := mgmt_short_string_array();
  p_event_obj.change_attr_list.EXTEND(6);
  p_event_obj.change_attr_list(1) := EM_EVENT_MANAGER.OPEN_STATUS ;
  p_event_obj.change_attr_list(2) := EM_EVENT_MANAGER.CLOSED_DATE ;
  p_event_obj.change_attr_list(3) := EM_EVENT_MANAGER.SUPPRESSED ;
  p_event_obj.change_attr_list(4) := EM_EVENT_MANAGER.PREVIOUS_SEVERITY ;
  p_event_obj.change_attr_list(5) := EM_EVENT_MANAGER.SEVERITY ;
  p_event_obj.change_attr_list(6) := EM_EVENT_MANAGER.PROCESSING_STATUS ;

  EM_EVENT_MANAGER.save_clear_event_raw_data (p_event_obj) ;

  IF p_event_obj.incident_id is not null
  THEN
    EM_EVENT_MANAGER.get_incident_details
        (p_incident_id => p_event_obj.incident_id, 
         p_inc_obj     => p_inc_obj,
         p_inc_rec     => l_inc_rec);
    populate_inc_rule_owners_on_ev(p_event_obj, p_inc_obj);
    p_inc_obj.repo_sysdate_utc := p_event_obj.repo_sysdate_utc;
    p_inc_obj.assoc_entity_close_count := p_inc_obj.assoc_entity_close_count + 1 ; --adjust close count
    p_inc_obj.processing_status := EM_EVENT_UTIL.ISSUE_UPDATE ; -- incident update
    IF p_inc_obj is not null and 
       p_inc_obj.assoc_entity_tot_count - p_inc_obj.assoc_entity_close_count = 0 --for single event-inc case
    THEN
      p_inc_obj.previous_severity := p_inc_obj.severity;
      p_inc_obj.severity := GC_EVENT_RECEIVER.CLEAR;
      p_inc_obj.open_status := EM_EVENT_UTIL.closed_event;
      p_inc_obj.closed_date := p_inc_obj.repo_sysdate_utc;
      p_inc_obj.last_severity_change := p_inc_obj.repo_sysdate_utc ;
      p_inc_obj.resolution_state := EM_EVENT_UTIL.res_state_closed ;
      p_inc_obj.last_res_state_change := p_inc_obj.repo_sysdate_utc ;
      p_inc_obj.change_attr_list := mgmt_short_string_array();
      p_inc_obj.change_attr_list.EXTEND(5);
      p_inc_obj.change_attr_list(1) := EM_EVENT_MANAGER.PREVIOUS_SEVERITY;
      p_inc_obj.change_attr_list(2) := EM_EVENT_MANAGER.SEVERITY ;
      p_inc_obj.change_attr_list(3) := EM_EVENT_MANAGER.OPEN_STATUS ;
      p_inc_obj.change_attr_list(4) := EM_EVENT_MANAGER.CLOSED_DATE ;
      p_inc_obj.change_attr_list(5) := EM_EVENT_MANAGER.PROCESSING_STATUS ;
      --end for single event-inc case
    --reevaluate incident severity only if the current cleared event has the highest severity
    ELSIF l_curr_evt_severity >= p_inc_obj.severity and
          p_inc_obj.assoc_entity_tot_count > 1 --multi events incident
    THEN 
      -- get the current highest level severity among the otherevents and check it against the incident
      SELECT max(severity) INTO l_curr_max_severity 
      FROM em_event_sequences PARTITION (OPEN) 
      WHERE incident_id = p_inc_obj.incident_id
        AND event_seq_id <> p_event_obj.event_seq_id
        AND open_status = EM_EVENT_UTIL.OPEN_EVENT
        AND closed_date = EM_EVENT_UTIL.OPEN_EV_DEFAULT_CLOSE_DATE ;
  
      -- if the severity has changed (if underlying open events become less severe), then set the new severity
      IF p_inc_obj.severity > l_curr_max_severity
      THEN
        p_inc_obj.previous_severity := p_inc_obj.severity ;
        p_inc_obj.severity := l_curr_max_severity;
        p_inc_obj.last_severity_change := p_inc_obj.repo_sysdate_utc ;
        p_inc_obj.change_attr_list := mgmt_short_string_array();
        p_inc_obj.change_attr_list.EXTEND(3);
        p_inc_obj.change_attr_list(1) := EM_EVENT_MANAGER.PREVIOUS_SEVERITY;
        p_inc_obj.change_attr_list(2) := EM_EVENT_MANAGER.SEVERITY ;
        p_inc_obj.change_attr_list(3) := EM_EVENT_MANAGER.PROCESSING_STATUS ;
      END IF ; --event severity change check
    END IF ; 
  END IF ;
  IF EMDW_LOG.P_IS_INFO_SET
  THEN
    EMDW_LOG.INFO('clear_stateless_event:Exit', 'CLEAR') ;
  END IF ;
END clear_stateless_event;


BEGIN 

--current_incident_id := 34118;
--current_event_seq_id := '293CE2C712EC454BE0535EB4F00AF6EB';

if current_incident_id != 0 then 
select trigger_event_seq into current_event_seq_id from em_incidents where incident_num = current_incident_id;
end if; 

dbms_output.put_line (current_event_seq_id);

clear_stateless_event (current_event_seq_id, SYSDATE );
em_event_manager.save_data(p_event_obj, p_inc_obj, p_pblm_obj,false,p_n1, p_n2, p_n3 );
commit;
END;
/