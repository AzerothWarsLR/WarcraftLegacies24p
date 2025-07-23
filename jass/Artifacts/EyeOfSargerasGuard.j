library EyeOfSargerasGuard requires Filters

globals
    constant integer ITEM_EYE_OF_SARG = 'I003'
    constant real    SEARCH_RADIUS    = 700.0  
    
    hashtable gg_effectTable = null
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
    effect  gg_overheadEffect = null
    effect  gg_missileEffect = null
    timer   gg_impactCleanupTimer = null
endglobals

function GetFreeInventorySlots takes unit u returns integer
    local integer freeSlots = 0
    local integer i = 0
    if GetUnitAbilityLevel(u, ARTIFACT_HOLDER_ABIL_ID) == 0 then
        call UnitAddAbility(u, ARTIFACT_HOLDER_ABIL_ID)
        call SetUnitAbilityLevel(u, ARTIFACT_HOLDER_ABIL_ID, 1)
    endif
    loop
        exitwhen i >= 6
        if UnitItemInSlot(u, i) == null then
            set freeSlots = freeSlots + 1
        endif
        set i = i + 1
    endloop
    return freeSlots
endfunction

function CleanupImpactEffect takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local effect fx = LoadEffectHandle(gg_effectTable, GetHandleId(t), 0)
    if fx != null then
        call DestroyEffect(fx)
    endif
    call RemoveSavedHandle(gg_effectTable, GetHandleId(t), 0)
    call DestroyTimer(t)
endfunction

function RemoveImpactEffect takes nothing returns nothing
    if gg_overheadEffect != null then
        call DestroyEffect(gg_overheadEffect)
        set gg_overheadEffect = null
    endif
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function OnMissileImpact takes nothing returns nothing
    local effect fx
    local trigger t
    local real targetX = GetUnitX(gg_target)
    local real targetY = GetUnitY(gg_target)
    local boolean itemAdded
    local real safeX = GetItemX(gg_eye)
    local real safeY = GetItemY(gg_eye)
    local timer impactTimer
    
    if gg_overheadEffect != null then
        call DestroyEffect(gg_overheadEffect)
        set gg_overheadEffect = null
    endif

    if not UnitAlive(gg_target) then
        call SetItemPosition(gg_eye, gg_curX, gg_curY)
        set fx = AddSpecialEffect("Objects\\SpawnModels\\Human\\HCancelDeath\\HCancelDeath.mdl", gg_curX, gg_curY)
        set impactTimer = CreateTimer()
        call SaveEffectHandle(gg_effectTable, GetHandleId(impactTimer), 0, fx)
        call TimerStart(impactTimer, 1.0, false, function CleanupImpactEffect)
        return
    endif

    if GetUnitAbilityLevel(gg_target, ARTIFACT_HOLDER_ABIL_ID) == 0 then
        call UnitAddAbility(gg_target, ARTIFACT_HOLDER_ABIL_ID)
        call SetUnitAbilityLevel(gg_target, ARTIFACT_HOLDER_ABIL_ID, 1)
    endif

    if GetItemTypeId(gg_eye) != ITEM_EYE_OF_SARG then
        set gg_eye = CreateItem(ITEM_EYE_OF_SARG, safeX, safeY)
    endif
    
    set itemAdded = UnitAddItem(gg_target, gg_eye)
    
    if itemAdded then
        set fx = AddSpecialEffect("Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdl", targetX, targetY)
        call BlzSetSpecialEffectScale(fx, 2.0)
        call BlzSetSpecialEffectTime(fx, 1.0)
        set impactTimer = CreateTimer()
        call SaveEffectHandle(gg_effectTable, GetHandleId(impactTimer), 0, fx)
        call TimerStart(impactTimer, 1.0, false, function CleanupImpactEffect)
        
        set gg_overheadEffect = AddSpecialEffectTarget("Doodads\\Cinematic\\EyeOfSargeras\\EyeOfSargeras.mdl", gg_target, "overhead")
        
        set t = CreateTrigger()
        call TriggerRegisterUnitEvent(t, gg_target, EVENT_UNIT_DEATH)
        call TriggerAddAction(t, function RemoveImpactEffect)
    else
        call SetItemPosition(gg_eye, safeX, safeY)
        set fx = AddSpecialEffect("Objects\\SpawnModels\\Human\\HCancelDeath\\HCancelDeath.mdl", safeX, safeY)
        set impactTimer = CreateTimer()
        call SaveEffectHandle(gg_effectTable, GetHandleId(impactTimer), 0, fx)
        call TimerStart(impactTimer, 1.0, false, function CleanupImpactEffect)
    endif
    
    if not itemAdded and (GetItemTypeId(gg_eye) != ITEM_EYE_OF_SARG) then
        set gg_eye = CreateItem(ITEM_EYE_OF_SARG, safeX, safeY)
    endif
    
    set gg_impacted = true
endfunction

function MissileTick takes nothing returns nothing
    local real dx = GetUnitX(gg_target) - gg_curX
    local real dy = GetUnitY(gg_target) - gg_curY
    local real dist = SquareRoot(dx * dx + dy * dy)
    local real step = gg_speed * gg_interval

    if gg_missileEffect != null then
        call DestroyEffect(gg_missileEffect)
    endif

    if dist <= step or not UnitAlive(gg_target) then
        if gg_missileEffect != null then
            call DestroyEffect(gg_missileEffect)
            set gg_missileEffect = null
        endif
        call PauseTimer(gg_timer)
        call DestroyTimer(gg_timer)
        set gg_timer = null
        call OnMissileImpact()
        return
    endif

    set gg_curX = gg_curX + dx / dist * step
    set gg_curY = gg_curY + dy / dist * step
    set gg_missileEffect = AddSpecialEffect("Abilities\\Spells\\Undead\\OrbOfDeath\\AnnihilationMissile.mdl", gg_curX, gg_curY)
endfunction

function ConditionEyePickup takes nothing returns boolean
    return GetItemTypeId(GetManipulatedItem()) == ITEM_EYE_OF_SARG
endfunction

function FilterHostile takes nothing returns boolean
    local unit u = GetFilterUnit()
return GetOwningPlayer(u) == Player(PLAYER_NEUTRAL_AGGRESSIVE) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_ANCIENT) and not IsUnitHeroEnum()
endfunction

function StartEyeMissile takes real sx, real sy, unit t returns nothing
    set gg_target = t
    set gg_curX = sx
    set gg_curY = sy
    set gg_impacted = false

    if gg_modelHash == 0 then
        set gg_modelHash = StringHash("Abilities\\Spells\\Undead\\OrbOfDeath\\AnnihilationMissile.mdl")
    endif

    set gg_timer = CreateTimer()
    call TimerStart(gg_timer, gg_interval, true, function MissileTick)
endfunction

function HandleEyePickup_Sargeras takes nothing returns nothing
    local unit pickup = GetTriggerUnit()
    local item picked = GetManipulatedItem()
    local real ux = GetUnitX(pickup)
    local real uy = GetUnitY(pickup)
    local group grp = gg_grp_Search
    local unit best = null
    local real bestD = -1.0
    local unit u
    local real dx
    local real dy
    local real dist2

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

        if best != null then
            if gg_overheadEffect != null then
                call DestroyEffect(gg_overheadEffect)
                set gg_overheadEffect = null
            endif

            set gg_eye = picked
            call RemoveItem(picked)  
            set gg_caster = pickup
            call StartEyeMissile(ux, uy, best)
        endif
    endif
endfunction


function InitEyePickupTrigger takes nothing returns nothing
    set gg_effectTable = InitHashtable()
    set gg_trg_EyePickup = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_EyePickup, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_EyePickup, Condition(function ConditionEyePickup))
    call TriggerAddAction(gg_trg_EyePickup, function HandleEyePickup_Sargeras)
    set gg_grp_Search = CreateGroup()
endfunction

endlibrary