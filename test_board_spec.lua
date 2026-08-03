local DIR = debug.getinfo(1, "S").source:sub(2):match("(.*[/\\])") or "./"

package.preload["gettext"] = function()
    return setmetatable({}, { __call = function(_, s) return s end })
end
package.path = DIR .. "common/?.lua;" .. DIR .. "?.lua;" .. package.path

describe("SandwichSudokuBoard", function()
    local Mod, SandwichSudokuBoard

    setup(function()
        Mod = require("board")
        SandwichSudokuBoard = Mod.SandwichSudokuBoard
    end)

    describe("new", function()
        it("creates a 9x9 board with no clues until generate is called", function()
            local b = SandwichSudokuBoard:new()
            assert.are.equal(9, b.n)
            assert.are.same({}, b.row_clues)
        end)
    end)

    describe("generate", function()
        it("fills a valid 9x9 solution and computes matching sandwich clues", function()
            math.randomseed(42)
            local b = SandwichSudokuBoard:new()
            b:generate("medium")
            local n = b.n
            for r = 1, n do
                local seen = {}
                for c = 1, n do seen[b.solution[r][c]] = true end
                for d = 1, n do assert.is_true(seen[d], "row " .. r .. " missing " .. d) end
            end

            for r = 1, n do
                local pos1, pos9
                for c = 1, n do
                    if b.solution[r][c] == 1 then pos1 = c end
                    if b.solution[r][c] == 9 then pos9 = c end
                end
                local lo, hi = math.min(pos1, pos9), math.max(pos1, pos9)
                local sum = 0
                for c = lo + 1, hi - 1 do sum = sum + b.solution[r][c] end
                assert.are.equal(sum, b.row_clues[r])
            end
        end)
    end)

    describe("recalcConflicts (sandwich violations)", function()
        it("flags a row whose filled sandwich sum is wrong", function()
            math.randomseed(42)
            local b = SandwichSudokuBoard:new()
            b:generate("medium")
            local r = 1
            for c = 1, b.n do
                if not b:isGiven(r, c) then
                    b.user[r][c] = b.solution[r][c]
                end
            end
            b.row_clues[r] = b.row_clues[r] + 1  -- force a mismatch
            b:recalcConflicts()
            local any_conflict = false
            for c = 1, b.n do
                if b.conflicts[r][c] then any_conflict = true end
            end
            assert.is_true(any_conflict)
        end)
    end)

    describe("serialize / load", function()
        it("round-trips puzzle, solution and clues", function()
            math.randomseed(42)
            local b = SandwichSudokuBoard:new()
            b:generate("medium")
            local data = b:serialize()

            local b2 = SandwichSudokuBoard:new()
            assert.is_true(b2:load(data))
            assert.are.same(b.row_clues, b2.row_clues)
            for r = 1, b.n do
                for c = 1, b.n do
                    assert.are.equal(b.solution[r][c], b2.solution[r][c])
                end
            end
        end)

        it("load returns false for invalid data", function()
            local b = SandwichSudokuBoard:new()
            assert.is_false(b:load(nil))
            assert.is_false(b:load({}))
        end)
    end)
end)
