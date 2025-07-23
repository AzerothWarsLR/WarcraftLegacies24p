library CheatResearch initializer OnInit requires TestSafety

    globals
        private constant string COMMAND = "-tech "  // 指令修改为 "-tech "
    endglobals

    private function Char2Id takes string c returns integer
        local integer i = 0
        local string abc = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        local string t

        loop
            set t = SubString(abc, i, i + 1)
            exitwhen t == null or t == c
            set i = i + 1
        endloop

        if i < 10 then
            return i + 48
        elseif i < 36 then
            return i + 65 - 10
        endif
        return i + 97 - 36
    endfunction

    private function S2Raw takes string s returns integer
        return ((Char2Id(SubString(s, 0, 1)) * 256 + Char2Id(SubString(s, 1, 2))) * 256 + Char2Id(SubString(s, 2, 3))) * 256 + Char2Id(SubString(s, 3, 4))
    endfunction

    private function SetTechLevel takes player p, integer techId, integer level returns nothing
        local string techName = GetObjectName(techId)
        call SetPlayerTechResearched(p, techId, level) 
        call DisplayTextToPlayer(p, 0, 0, "|cffD27575CHEAT:|r Set tech " + techName + " to level " + I2S(level) + ".")
    endfunction

    private function Actions takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local string chatStr = GetEventPlayerChatString()
        local integer cmdLen = StringLength(COMMAND)  // 自动适配新指令长度
        local string paramStr = SubString(chatStr, cmdLen, StringLength(chatStr))
        local string techIdStr
        local string levelStr
        local integer techId
        local integer level

        if StringLength(paramStr) >= 4 then
            set techIdStr = SubString(paramStr, 0, 4)
        else
            call DisplayTextToPlayer(p, 0, 0, "|cffD27575CHEAT:|r Invalid tech ID format")
            return
        endif

        if StringLength(paramStr) > 4 then
            set levelStr = SubString(paramStr, 4, StringLength(paramStr))
        else
            set levelStr = "1" 
        endif

        set techId = S2Raw(techIdStr)
        set level = S2I(levelStr)

        // 执行设置科技等级逻辑
        if techId != 0 then
            call SetTechLevel(p, techId, level)
        else
            call DisplayTextToPlayer(p, 0, 0, "|cffD27575CHEAT:|r Invalid tech ID")
        endif
    endfunction

    private function OnInit takes nothing returns nothing
        local trigger trig = CreateTrigger()
        local integer i = 0

        loop
            exitwhen i > MAX_PLAYERS
            call TriggerRegisterPlayerChatEvent(trig, Player(i), COMMAND, false)  // 监听新指令
            set i = i + 1
        endloop

        call TriggerAddCondition(trig, Condition(function CheatCondition))
        call TriggerAddAction(trig, function Actions)
    endfunction

endlibrary