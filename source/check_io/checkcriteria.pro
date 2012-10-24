function Check_Criteria, request, result

  crit=0
  startIndex=request->getStartIndex()
  endIndex=request->getEndIndex()
  parCodes=request->getParameterCodes()
  modelInfo=request->getModelInfo()
  year=modelInfo.year
  scale=modelInfo.scale
  scaleName=strupcase(scale)
  hourStat=request->getGroupByTimeInfo() ;HourType
  flag_average=hourStat[0].value
  statType=request->getGroupByStatInfo() ;HourType
  isGroupSelection=request->isGroupObsPresent()
  isSingleSelection=request->isSingleObsPresent()
  elabcode=request->getElaborationCode()
  ;MM summer 2012 End
  GroupModeOKmode=0
  if isSingleSelection then GroupModeOKmode=1
  if isGroupSelection then GroupModeOKmode=request->getGroupStatToApplyCode()

  if n_elements(parCodes) gt 1 or GroupModeOKmode ne 1 then begin
    crit=0
    goto,jumpEnd
  endif

  if flag_average eq 'preserve' then flag_average='P'
  if flag_average eq '08' then flag_average='8H'

  if statType eq 0 then flagDailyStat='P'
  if statType eq 1 then flagDailyStat='MEAN'
  if statType eq 2 then flagDailyStat='MAX'
  if statType eq 3 then flagDailyStat='MIN'

  dailyStatOp=flag_average+flagDailyStat

  if elabCode eq 32 or elabcode eq 21 or elabCode eq 84 then begin  ;annual averages
    if parcodes[0] eq 'PM10' then dailyStatOp='PMEAN'
    if parcodes[0] eq 'NO2'  then dailyStatOp='PP'
    if parcodes[0] eq 'O3'   then dailyStatOp='N/A'
  endif

  Criteria=request->getGoalsCriteriaValues(parameter=parCodes[0], scalename=scalename, statname='OU', timeAvgName=dailyStatOp, NOVALUES=NOVALUES)
  if criteria(0) gt 0 then crit=1
  if Criteria(0) eq -1 then begin
     Criteria=request->getGoalsCriteriaValues(parameter=parCodes[0], scalename=scalename, statname='OU', timeAvgName='ALL', NOVALUES=NOVALUES)
     if criteria(0) gt 0 then crit=1
  endif

  jumpend:
  return,crit
;**********************
end