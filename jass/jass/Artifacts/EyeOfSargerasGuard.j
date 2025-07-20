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

function GetInventorySize takes unit u returns integer
    local integer slots = 0
    local integer i = 0
    loop
        exitwhen i >= 6
        if UnitInventorySize(u) > i then
            set slots = slots + 1
        endif
        set i = i + 1
    endloop
    return slots
endfunction

function RemoveImpactEffect takes nothing returns nothing
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function OnMissileImpact takes nothing returns nothing
    local effect fx
    local trigger t
    local real targetX
    local real targetY
    local integer initialSlots
    local integer slotsAfterAbility
    local integer finalSlots
    local boolean itemAdded
    
    set targetX = GetUnitX(gg_target)
    set targetY = GetUnitY(gg_target)
    set initialSlots = GetInventorySize(gg_target)
    
    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Initial inventory slots: " + I2S(initialSlots))

    if not UnitAlive(gg_target) then
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Target died before impact")
        call SetItemPosition(gg_eye, gg_curX, gg_curY)
        set fx = AddSpecialEffect("Objects\\SpawnModels\\Human\\HCancelDeath\\HCancelDeath.mdl", gg_curX, gg_curY)
        call DestroyEffect(fx)
        return
    endif

    // First move item to a safe location
    call SetItemPosition(gg_eye, 20229, 24244)
    
    // Add inventory ability FIRST
    call UnitAddAbility(gg_target, 'A01Y')
    
    // Check slots after ability
    set slotsAfterAbility = GetInventorySize(gg_target)
    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Slots after ability: " + I2S(slotsAfterAbility))
    
    // Small delay to ensure ability is properly added
    call TriggerSleepAction(0.01)
    
    // Try to add item using UnitAddItem (standard function)
    set itemAdded = UnitAddItem(gg_target, gg_eye)
    if itemAdded then
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Item successfully added to unit")
        // Success - add effects
        set fx = AddSpecialEffect("Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdl", targetX, targetY)
        call BlzSetSpecialEffectScale(fx, 2.0)
        call BlzSetSpecialEffectTime(fx, 1.0)
        
        // Add overhead effect
        set fx = AddSpecialEffectTarget("Doodads\\Cinematic\\EyeOfSargeras\\EyeOfSargeras.mdl", gg_target, "overhead")
        
        // Create death trigger for cleanup
        set t = CreateTrigger()
        call TriggerRegisterUnitEvent(t, gg_target, EVENT_UNIT_DEATH)
        call TriggerAddAction(t, function RemoveImpactEffect)
    else
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Failed to add item to unit")
        // If failed, drop at missile location
        call UnitRemoveAbility(gg_target, 'A01Y')
        call SetItemPosition(gg_eye, gg_curX, gg_curY)
        set fx = AddSpecialEffect("Objects\\SpawnModels\\Human\\HCancelDeath\\HCancelDeath.mdl", gg_curX, gg_curY)
        call DestroyEffect(fx)
    endif
    
    set finalSlots = GetInventorySize(gg_target)
    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Final inventory slots: " + I2S(finalSlots))
    
    // Debug item location
    if not itemAdded then
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Eye location: " + R2S(GetItemX(gg_eye)) + ", " + R2S(GetItemY(gg_eye)))
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
    local unit u = GetFilterUnit()
    return GetOwningPlayer(u) == Player(PLAYER_NEUTRAL_AGGRESSIVE) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_ANCIENT)
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
    local real   bestD  = -1.0
    local unit   u
    local real   dx
    local real   dy
    local real   dist2

    // Only proceed if picker is NOT neutral aggressive
    if GetOwningPlayer(pickup) != Player(PLAYER_NEUTRAL_AGGRESSIVE) then
        call GroupClear(grp)
        call GroupEnumUnitsInRange(grp, ux, uy, SEARCH_RADIUS, Condition(function FilterHostile))

        loop
            set u = FirstOfGroup(grp)
            exitwhen u == null
            call GroupRemoveUnit(grp, u)

            set dx = GetUnitX(u) - ux
            set dy = GetUnitY(u) - uy
            set dist2 = dx * dx + dy * dy

            if dist2 > bestD then
                set bestD = dist2
                set best = u
            endif
        endloop

        if best == null then
            return
        endif

        set gg_eye = picked
        call RemoveItem(picked)
        set gg_caster = pickup
        call StartEyeMissile(ux, uy, best)
    endif
endfunction

function InitEyePickupTrigger takes nothing returns nothing
    set gg_trg_EyePickup = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_EyePickup, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_EyePickup, Condition(function ConditionEyePickup))
    call TriggerAddAction(gg_trg_EyePickup, function HandleEyePickup_Sargeras)
    set gg_grp_Search = CreateGroup()
endfunction

endlibrary