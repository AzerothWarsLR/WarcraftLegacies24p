library EyeOfSargerasGuard

globals
    constant integer ITEM_EYE_OF_SARG = 'I003'
    constant real    SEARCH_RADIUS    = 700.0
    
    trigger gg_trg_EyePickup
    group   gg_grp_Search
    timer   gg_timer
    unit    gg_target
    unit    gg_caster
    item    gg_eye
    real    gg_curX
    real    gg_curY
    real    gg_speed     = 700.0
    real    gg_interval  = 0.03
    integer gg_modelHash = 0
    boolean gg_impacted
endglobals

function RemoveImpactEffect takes nothing returns nothing
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function OnMissileImpact takes nothing returns nothing
    local effect fx
    local trigger t

    if not UnitAlive(gg_target) then
        call SetItemPosition(gg_eye, gg_curX, gg_curY)
    else
        call UnitAddAbility(gg_target, 'A01Y')
        call UnitAddItem(gg_target, gg_eye)
        set fx = AddSpecialEffect("Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdl", GetUnitX(gg_target), GetUnitY(gg_target))
        call BlzSetSpecialEffectScale(fx, 2.0)
        call BlzSetSpecialEffectTime(fx, 1.0)

        set t = CreateTrigger()
        call TriggerRegisterUnitEvent(t, gg_target, EVENT_UNIT_DEATH)
        call TriggerAddAction(t, function RemoveImpactEffect)
    endif

    set gg_impacted = true
endfunction


function MissileTick takes nothing returns nothing
    local real dx   = GetUnitX(gg_target) - gg_curX
    local real dy   = GetUnitY(gg_target) - gg_curY
    local real dist = SquareRoot(dx * dx + dy * dy)
    local real step = gg_speed * gg_interval

    if dist <= step or not UnitAlive(gg_target) then
        call PauseTimer(gg_timer)
        call DestroyTimer(gg_timer)
        call OnMissileImpact()
        return
    endif

    set gg_curX = gg_curX + dx / dist * step
    set gg_curY = gg_curY + dy / dist * step
    call AddSpecialEffect("Abilities\\Spells\\Undead\\OrbOfDeath\\AnnihilationMissile.mdl", gg_curX, gg_curY)
endfunction

function ConditionEyePickup takes nothing returns boolean
    return GetItemTypeId(GetManipulatedItem()) == ITEM_EYE_OF_SARG
endfunction

function FilterHostile takes nothing returns boolean
    local boolean isHostile = (GetOwningPlayer(GetFilterUnit()) == Player(PLAYER_NEUTRAL_AGGRESSIVE))
    local boolean isAlive = UnitAlive(GetFilterUnit())
    local boolean isNotAncient = not IsUnitType(GetFilterUnit(), UNIT_TYPE_ANCIENT)
    return isHostile and isAlive and isNotAncient
endfunction

function StartEyeMissile takes real sx, real sy, unit t returns nothing
    set gg_target   = t
    set gg_curX     = sx
    set gg_curY     = sy
    set gg_impacted = false

    if gg_modelHash == 0 then
        set gg_modelHash = StringHash("Abilities\\Spells\\Undead\\OrbOfDeath\\AnnihilationMissile.mdl")
    endif

    set gg_timer = CreateTimer()
    call TimerStart(gg_timer, gg_interval, true, function MissileTick)
endfunction

function HandleEyePickup_Sargeras takes nothing returns nothing
    local unit   pickup = GetTriggerUnit()
    local item   picked = GetManipulatedItem()
    local real   ux     = GetUnitX(pickup)
    local real   uy     = GetUnitY(pickup)
    local group  grp    = gg_grp_Search
    local unit   best   = null
    local real   bestD  = 0.0
    local unit   u
    local real   dx
    local real   dy
    local real   dist2

    if GetOwningPlayer(pickup) == Player(PLAYER_NEUTRAL_AGGRESSIVE) then
        return
    endif

    call GroupClear(grp)
    call GroupEnumUnitsInRange(grp, ux, uy, SEARCH_RADIUS, Condition(function FilterHostile))

    loop
        set u = FirstOfGroup(grp)
        exitwhen u == null
        call GroupRemoveUnit(grp, u)

        if FilterHostile() then
            set dx = GetUnitX(u) - ux
            set dy = GetUnitY(u) - uy
            set dist2 = dx * dx + dy * dy

            if dist2 > bestD then
                set bestD = dist2
                set best  = u
            endif
        endif
    endloop

    if best == null then
        call TriggerAddAction(gg_trg_EyePickup, function HandleEyePickup_Sargeras)
        return
    endif

    call RemoveItem(picked)
    set gg_caster = pickup
    set gg_eye    = picked
    call StartEyeMissile(ux, uy, best)
endfunction

function InitEyePickupTrigger takes nothing returns nothing
    set gg_trg_EyePickup = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_EyePickup, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_EyePickup, Condition(function ConditionEyePickup))
    call TriggerAddAction(gg_trg_EyePickup, function HandleEyePickup_Sargeras)
    set gg_grp_Search = CreateGroup()
endfunction

endlibrary
