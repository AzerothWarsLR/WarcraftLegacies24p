library QuestItemLegendHasAnyArtifact initializer OnInit requires QuestItemData, Artifact, Legend 

  globals 
    Artifact finalArtifact = 0
  endglobals 

  struct QuestItemLegendHasAnyArtifact extends QuestItemData 
    private static integer count = 0 
    private static thistype array byIndex 
    private Legend targetLegend 
    private Artifact array targetArtifacts[5] 

    // 任务添加时的初始化，不直接检查进度  
    private method OnAdd takes nothing returns nothing 
      set this.Progress = QUEST_PROGRESS_INCOMPLETE 
    endmethod 

    // 神器获取状态变更时检查进度  
    private method OnAcquired takes nothing returns nothing 
      call this.CheckAnyArtifactOwned() 
    endmethod 

    // 核心检查逻辑：判断是否拥有任意一个目标神器，仅在调用时更新进度  
    private method CheckAnyArtifactOwned takes nothing returns nothing 
      if(this.targetArtifacts[0] != null and this.targetArtifacts[0].OwningUnit == this.targetLegend.Unit) then
        set this.Progress = QUEST_PROGRESS_COMPLETE   
        return 

      elseif (this.targetArtifacts[1] != null and this.targetArtifacts[1].OwningUnit == this.targetLegend.Unit) then
        set this.Progress = QUEST_PROGRESS_COMPLETE 
        return 

      elseif (this.targetArtifacts[2] != null and this.targetArtifacts[2].OwningUnit == this.targetLegend.Unit) then 
        set this.Progress = QUEST_PROGRESS_COMPLETE 
        return 

      elseif (this.targetArtifacts[3] != null and this.targetArtifacts[3].OwningUnit == this.targetLegend.Unit) then
        set this.Progress = QUEST_PROGRESS_COMPLETE 
        return 

      elseif (this.targetArtifacts[4] != null and this.targetArtifacts[4].OwningUnit == this.targetLegend.Unit) then
        set this.Progress = QUEST_PROGRESS_COMPLETE 
        return 

      endif 
      set this.Progress = QUEST_PROGRESS_INCOMPLETE 
    endmethod 

    // 全局神器变更监听逻辑  
    static method OnAnyArtifactAcquired takes nothing returns nothing 
      local integer i = 0 
      local thistype loopItem 
      local Artifact trigArt = GetTriggerArtifact() 

      loop 
        exitwhen i >= thistype.count 
        set loopItem = thistype.byIndex[i] 
        // 检查触发变更的神器是否是任务目标之一  
        if loopItem.targetArtifacts[0] != null and loopItem.targetArtifacts[0] == trigArt then 
          call loopItem.OnAcquired() 
        endif 
        if loopItem.targetArtifacts[1] != null and loopItem.targetArtifacts[1] == trigArt then 
          call loopItem.OnAcquired() 
        endif 
        if loopItem.targetArtifacts[2] != null and loopItem.targetArtifacts[2] == trigArt then 
          call loopItem.OnAcquired() 
        endif 
        if loopItem.targetArtifacts[3] != null and loopItem.targetArtifacts[3] == trigArt then 
          call loopItem.OnAcquired() 
        endif 
        if loopItem.targetArtifacts[4] != null and loopItem.targetArtifacts[4] == trigArt then 
          call loopItem.OnAcquired() 
        endif 
        set i = i + 1 
      endloop 
    endmethod 

    // 创建任务实例的方法  
    static method create takes Legend targetLegend, Artifact a1, Artifact a2, Artifact a3, Artifact a4, Artifact a5 returns thistype 
      local thistype this = thistype.allocate() 
      local string desc = targetLegend.Name + " has one of the required Artifacts" 
            
      set this.targetArtifacts[0] = a1 
      set this.targetArtifacts[1] = a2 
      set this.targetArtifacts[2] = a3 
      set this.targetArtifacts[3] = a4 
      set this.targetArtifacts[4] = a5 
      set this.targetLegend = targetLegend 
      set this.Description = desc 
      set this.Progress = QUEST_PROGRESS_INCOMPLETE 
            
      set thistype.byIndex[thistype.count] = this 
      set thistype.count = thistype.count + 1 
            
      return this 
    endmethod 
  endstruct 

  private function OnInit takes nothing returns nothing 
    local trigger trig = CreateTrigger() 
    call OnArtifactOwnerChange.register(trig) 
    call TriggerAddAction(trig, function QuestItemLegendHasAnyArtifact.OnAnyArtifactAcquired)
  endfunction 

endlibrary   