library LegendCthun initializer OnInit requires Legend

  globals
    Legend LEGEND_SKERAM
    Legend LEGEND_GATESAHNQIRAJ
    Legend LEGEND_CTHUN
    Legend LEGEND_YOR

  endglobals

  private function OnInit takes nothing returns nothing

    set LEGEND_CTHUN = Legend.create("")
    set LEGEND_CTHUN.Unit = gg_unit_U00R_0609
    set LEGEND_CTHUN.PermaDies = true
    set LEGEND_CTHUN.IsCapital = true  
    set LEGEND_CTHUN.DeathMessage = "C'thun, God of the Qiraji, was once defeated by the Titans, and then again by the combined Dragonflights. Today he experiences his third defeat and his first true death."

    set LEGEND_SKERAM = Legend.create("")
    set LEGEND_SKERAM.UnitType = 'E005'
    set LEGEND_SKERAM.PlayerColor = PLAYER_COLOR_RED
    set LEGEND_SKERAM.Name = "Prophet Skeram"

    set LEGEND_GATESAHNQIRAJ = Legend.create("")
    set LEGEND_GATESAHNQIRAJ.Unit = gg_unit_h02U_2413

    set LEGEND_YOR = Legend.create("")
    set LEGEND_YOR.UnitType = 'U02A'
    set LEGEND_YOR.StartingXP = 8800

  endfunction

endlibrary