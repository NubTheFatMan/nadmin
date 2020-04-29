hook.Add("ScoreboardShow", "nadmin_open_scoreboard", function()
    if nadmin.plugins.scoreboard then
        nadmin.scoreboard:Show()
        nadmin.scoreboard.shouldClose = false
        return true
    end
end)
hook.Add("ScoreboardHide", "nadmin_close_scoreboard", function()
    if IsValid(nadmin.scoreboard.player) and istable(nadmin.scoreboard.cmd) then nadmin.scoreboard.shouldClose = true return end
    nadmin.scoreboard:Hide()
end)
