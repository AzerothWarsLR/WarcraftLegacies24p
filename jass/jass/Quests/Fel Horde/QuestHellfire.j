library QuestHellfire requires QuestData, IronforgeSetup, QuestItemKillUnit

  globals
    private constant integer QUEST_RESEARCH_ID = 'R00P'
  endglobals

  struct QuestHellfire extends QuestData
    private method operator CompletionPopup takes nothing returns string
      return "Hellfire Citadel has been subjugated, and its military is now free to assist the " + this.Holder.Team.Name + "."
    endmethod

    private method operator CompletionDescription takes nothing returns string
      return "Control of all units in Hellfire Citadel and enable Kargath to be trained at the altar"
    endmethod

    private method GrantHellfire takes player whichPlayer returns nothing
      local unit u

      //Transfer all Neutral Passive units in Hellfire Citadel
      set u = FirstOfGroup(udg_HellfireGroup)
      loop
      exitwhen u == null
        if GetOwningPlayer(u) == Player(PLAYER_NEUTRAL_AGGRESSIVE) then
          call UnitRescue(u, whichPlayer)
        endif
        call GroupRemoveUnit(udg_HellfireGroup, u)
        set u = FirstOfGroup(udg_HellfireGroup)
      endloop
      call DestroyGroup(udg_HellfireGroup)
      set udg_HellfireGroup = null      
    endmethod

    private method OnComplete takes nothing returns nothing
      call UnitRescue(gg_unit_n081_0882, FACTION_FEL_HORDE.Player)
      call UnitRescue(gg_unit_n081_0717, FACTION_FEL_HORDE.Player)
      call UnitRescue(gg_unit_ndfl_0551, FACTION_FEL_HORDE.Player)
      call SetPlayerTechResearched(Holder.Player, 'R00P', 1) 
      call this.GrantHellfire(this.Holder.Player)
      if GetLocalPlayer() == this.Holder.Player then
        call PlayThematicMusicBJ( "war3mapImported\\FelTheme.mp3" )
      endif
    endmethod

    private method OnFail takes nothing returns nothing
      call this.GrantHellfire(Player(PLAYER_NEUTRAL_AGGRESSIVE))
    endmethod

    private method OnAdd takes nothing returns nothing
      call this.Holder.ModObjectLimit(QUEST_RESEARCH_ID, 1)
    endmethod

    public static method create takes nothing returns thistype
      local thistype this = thistype.allocate("The Citadel", "The clans holding Hellfire Citadel do not respect Kargath authority yet, destroy Murmur to finally establish Magtheridon as the undisputable king of Outland", "ReplaceableTextures\\CommandButtons\\BTNFelOrcFortress.blp")
      call this.AddQuestItem(QuestItemLegendDead.create(LEGEND_EXODARSHIP))
      call this.AddQuestItem(QuestItemControlPoint.create(ControlPoint.ByUnitType('n01J')))
      call this.AddQuestItem(QuestItemControlPoint.create(ControlPoint.ByUnitType('n02N')))
      call this.AddQuestItem(QuestItemUpgrade.create('o030', 'o02Y'))
      call this.AddQuestItem(QuestItemExpire.create(1450))
      call this.AddQuestItem(QuestItemSelfExists.create())
      return this
    endmethod
  endstruct

endlibrary