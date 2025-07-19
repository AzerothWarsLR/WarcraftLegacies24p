library CripplingShout initializer OnInit requires DummyCast, Filters

  globals
    private constant integer ABIL_ID        = 'A0ZS'
    private constant integer DUMMY_ID       = 'A0ZT'        //The ability that gets cast on each unit in the radius
    private constant string  DUMMY_ORDER    = "cripple"
    private constant real    RADIUS         = 700.00
    private group     TempGroup = CreateGroup()
  endglobals
 
  private function Cast takes nothing returns nothing
    local unit u
    local unit caster
    local integer level        
    set caster = GetTriggerUnit()
    set level = GetUnitAbilityLevel(caster, ABIL_ID)             
    set P = GetOwningPlayer(caster)
    call GroupEnumUnitsInRange(TempGroup,GetUnitX(caster),GetUnitY(caster),RADIUS,Condition(function EnemyAliveFilter))
    loop
      set u = FirstOfGroup(TempGroup)
      exitwhen u == null
      call DummyCastUnit(GetOwningPlayer(caster), DUMMY_ID, DUMMY_ORDER, 1, u)
      call GroupRemoveUnit(TempGroup,u)
    endloop
  endfunction

  private function OnInit takes nothing returns nothing
    call RegisterSpellEffectAction(ABIL_ID, function Cast)
  endfunction 
    
endlibrary
