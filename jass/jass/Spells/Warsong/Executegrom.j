//When a Ravager reduces an enemy units hit points such that it ends up with less than 500% of the Ravager's damage, it dies instantly.
library Executegrom initializer OnInit requires FilteredDamageEvents, GeneralHelpers

  globals
    private constant string EFFECT = "Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl"
    private constant integer DAMAGE_MULT = 4
  endglobals

  private function OnDamage takes nothing returns nothing
    local unit triggerUnit = GetTriggerUnit()
    if BlzGetEventIsAttack() and GetUnitState(triggerUnit, UNIT_STATE_LIFE) < GetEventDamage() + GetUnitAverageDamage(GetEventDamageSource(), 0) * DAMAGE_MULT and GetPlayerTechResearched(Player(5),'R08M',true) == true then
      call BlzSetEventDamage(GetUnitState(triggerUnit, UNIT_STATE_LIFE) + 1)
      call DestroyEffect(AddSpecialEffectTarget(EFFECT, triggerUnit, "origin"))
    endif
    set triggerUnit = null
  endfunction

  private function OnInit takes nothing returns nothing
    call RegisterUnitTypeInflictsDamageAction('Ogrh', function OnDamage)
  endfunction

endlibrary