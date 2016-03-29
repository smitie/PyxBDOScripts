Navigator = { }
Navigator.Running = false
Navigator.Destination = Vector3(0, 0, 0)
Navigator.Waypoints = { }
Navigator.ApproachDistance = 50
Navigator.LastStuckCheckTickcount = 0
Navigator.LastStuckCheckPosition = Vector3(0, 0, 0)

function Navigator.CanMoveTo(destination)
    
    local selfPlayer = GetSelfPlayer()
    
    if not selfPlayer then
        return false
    end
    
    local waypoints = Navigation.FindPath(selfPlayer.Position, destination)
    
    if table.length(waypoints) == 0 then
        return false
    end
    
    if waypoints[#waypoints]:GetDistance3D(destination) > 100 then
        return false
    end
    
    return true
    
end

function Navigator.MoveToStraight(destination)
    local selfPlayer = GetSelfPlayer()
    Navigator.Waypoints = { }
    table.insert(Navigator.Waypoints, destination)
    Navigator.Destination = destination
    Navigator.Running = true
end

function Navigator.MoveTo(destination)
    
    local selfPlayer = GetSelfPlayer()
    
    if not selfPlayer then
        return false
    end
    
    local waypoints = Navigation.FindPath(selfPlayer.Position, destination)
    
    if table.length(waypoints) == 0 then
        print("Cannot find path !")
        return false
    end
    
    if waypoints[#waypoints]:GetDistance3D(destination) > 500 then
        print("Last waypoint was too far from destination !")
        return false
    end
    
    while waypoints[1] and waypoints[1].Distance2DFromMe < Navigator.ApproachDistance do
        table.remove(waypoints, 1)
    end
    
    Navigator.Waypoints = waypoints
    Navigator.Destination = destination
    Navigator.Running = true
    return true
end

function Navigator.Stop()
    Navigator.Waypoints = { }
    Navigator.Running = false
    Navigator.Destination = Vector3(0, 0, 0)
    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        selfPlayer:MoveTo(Navigator.Destination)
    end
end

function Navigator.OnPulse()
    local selfPlayer = GetSelfPlayer()
    
    if selfPlayer and not selfPlayer.IsRunning then 
        Navigator.LastStuckCheckTickcount = Pyx.System.TickCount
        Navigator.LastStuckCheckPosition = selfPlayer.Position
    end
    
    if Navigator.Running and selfPlayer then
        
        if Pyx.System.TickCount - Navigator.LastStuckCheckTickcount > 400 then
            if (Navigator.LastStuckCheckPosition.Distance2DFromMe < 40) then
                print("I'm stuck, jump forward !")
                selfPlayer:DoAction("JUMP_F_A")
            end
            Navigator.LastStuckCheckTickcount = Pyx.System.TickCount
            Navigator.LastStuckCheckPosition = selfPlayer.Position
        end
        
        local nextWaypoint = Navigator.Waypoints[1]
        if nextWaypoint then
            if nextWaypoint.Distance2DFromMe > Navigator.ApproachDistance then
                selfPlayer:MoveTo(nextWaypoint)
            else
                table.remove(Navigator.Waypoints, 1)
            end
        end
    end
end

function Navigator.OnRender3D()
    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        local linesList = { }
        for k,v in pairs(Navigator.Waypoints) do
            Renderer.Draw3DTrianglesList(GetInvertedTriangleList(v.X, v.Y + 20, v.Z, 10, 20, 0xFFFFFFFF, 0xFFFFFFFF))
        end
        local firstPoint = Navigator.Waypoints[1]
        if firstPoint then
            table.insert(linesList, { selfPlayer.Position.X, selfPlayer.Position.Y + 20, selfPlayer.Position.Z, 0xFFFFFFFF })
            table.insert(linesList, { firstPoint.X, firstPoint.Y + 20, firstPoint.Z, 0xFFFFFFFF })
        end
        for k,v in ipairs(Navigator.Waypoints) do
            local nextPoint = Navigator.Waypoints[k+1]
            if nextPoint then
                table.insert(linesList, { v.X, v.Y + 20, v.Z, 0xFFFFFFFF })
                table.insert(linesList, { nextPoint.X, nextPoint.Y + 20, nextPoint.Z, 0xFFFFFFFF })
            end
        end
        if table.length(linesList) > 0 then
            Renderer.Draw3DLinesList(linesList)
        end
    end
end
