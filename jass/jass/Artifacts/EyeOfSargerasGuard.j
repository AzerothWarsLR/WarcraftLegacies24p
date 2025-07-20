
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

function B2S takes boolean b returns string
    if b then
        return "true"
    endif
    return "false"
endfunction

function RemoveImpactEffect takes nothing returns nothing
    call DestroyTrigger(GetTriggeringTrigger())
endfunction


function OnMissileImpact takes nothing returns nothing
    local effect fx
    local trigger t
    local boolean canReceiveItems
    local real targetX = GetUnitX(gg_target)
    local real targetY = GetUnitY(gg_target)

    call BJDebugMsg("Missile Impact at X: " + R2S(targetX) + " Y: " + R2S(targetY))

    if not UnitAlive(gg_target) then
        call BJDebugMsg("Target dead - dropping item at impact location")
        call SetItemPosition(gg_eye, gg_curX, gg_curY)
        call SetItemVisible(gg_eye, true)
    else
        // Check if unit can receive items (has inventory)
        set canReceiveItems = not IsUnitType(gg_target, UNIT_TYPE_STRUCTURE) and UnitInventorySize(gg_target) > 0
        
        if canReceiveItems then
            call BJDebugMsg("Target can receive items - attempting to give")
            // First try to add ability
            call UnitAddAbility(gg_target, 'A01Y')
            
            // Try to add item safely
            call SetItemPosition(gg_eye, targetX, targetY)
            if UnitAddItem(gg_target, gg_eye) then
                call BJDebugMsg("Item added successfully")
                
                set fx = AddSpecialEffect("Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdl", targetX, targetY)
                call BlzSetSpecialEffectScale(fx, 2.0)
                call BlzSetSpecialEffectTime(fx, 1.0)

                set t = CreateTrigger()
                call TriggerRegisterUnitEvent(t, gg_target, EVENT_UNIT_DEATH)
                call TriggerAddAction(t, function RemoveImpactEffect)
            else
                call BJDebugMsg("Failed to add item - dropping near target")
                // If item couldn't be added, drop it near the target
                call SetItemPosition(gg_eye, targetX + 50, targetY)
                call SetItemVisible(gg_eye, true)
                // Remove the ability since we couldn't add the item
                call UnitRemoveAbility(gg_target, 'A01Y')
            endif
        else
            call BJDebugMsg("Target cannot receive items - dropping near target")
            // Drop the item near the target unit
            call SetItemPosition(gg_eye, targetX + 50, targetY)
            call SetItemVisible(gg_eye, true)
        endif
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
    call BJDebugMsg("Checking Eye pickup condition")
    return GetItemTypeId(GetManipulatedItem()) == ITEM_EYE_OF_SARG
endfunction

function FilterHostile takes nothing returns boolean
    local unit u = GetFilterUnit()
    local boolean isHostile = (GetOwningPlayer(u) == Player(PLAYER_NEUTRAL_AGGRESSIVE))
    local boolean isAlive = UnitAlive(u)
    local boolean isNotAncient = not IsUnitType(u, UNIT_TYPE_ANCIENT)
    call BJDebugMsg("Checking unit - Hostile: " + B2S(isHostile) + " Alive: " + B2S(isAlive) + " NotAncient: " + B2S(isNotAncient))
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
    local real   bestD  = -1.0
    local unit   u
    local real   dx
    local real   dy
    local real   dist2

    call BJDebugMsg("Handle Eye pickup triggered")

    // Only proceed if picker is NOT neutral aggressive
    if GetOwningPlayer(pickup) != Player(PLAYER_NEUTRAL_AGGRESSIVE) then
        call BJDebugMsg("Valid pickup unit detected")
        
        call GroupClear(grp)
        call GroupEnumUnitsInRange(grp, ux, uy, SEARCH_RADIUS, Condition(function FilterHostile))
        call BJDebugMsg("Searching for hostiles in range: " + R2S(SEARCH_RADIUS))

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
                call BJDebugMsg("Found potential target at distance: " + R2S(SquareRoot(dist2)))
            endif
        endloop

        if best == null then
            call BJDebugMsg("No valid targets found")
            return
        endif

        call BJDebugMsg("Target found - launching missile")
        set gg_eye = picked  // Store reference to item first
        call RemoveItem(picked)  // Then remove it from original holder
        set gg_caster = pickup
        call StartEyeMissile(ux, uy, best)
    else
        call BJDebugMsg("Pickup by neutral aggressive unit - ignoring")
    endif
endfunction

function InitEyePickupTrigger takes nothing returns nothing
    set gg_trg_EyePickup = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_EyePickup, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_EyePickup, Condition(function ConditionEyePickup))
    call TriggerAddAction(gg_trg_EyePickup, function HandleEyePickup_Sargeras)
    set gg_grp_Search = CreateGroup()
    call BJDebugMsg("Eye of Sargeras Guard Initialized")
endfunction

endlibrary