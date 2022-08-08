local Blip = nil
local BlizuPosla = false
local AktiviranPosao = false
local PosaoObjekt = {}
local PosaoBlip = {}
local BrojObjekata = 0
local PorukaPokazana = false

-- Blip

Citizen.CreateThread(function()
    Blip = N_0x554d9d53f696d002(1664425300, Config.Posao.X, Config.Posao.Y, Config.Posao.Z)
    SetBlipSprite(Blip, Config.Posao.Ikona, 1)
    Citizen.InvokeNative(0x9CB1A1623062F402, Blip, Config.Posao.Naziv) 
end)

Citizen.CreateThread(function()
    while true do
        if(GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Posao.X, Config.Posao.Y, Config.Posao.Z, true) < 2.0) then
            if BlizuPosla == false then BlizuPosla = true end
        else
            if BlizuPosla == true then BlizuPosla = false end
        end
        --
        if AktiviranPosao == true and BrojObjekata > 0 then
            if(GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Posao.X, Config.Posao.Y, Config.Posao.Z, true) > 50.0) then
                PrekiniPosao()
                TriggerEvent("vorp:TipBottom", "Otisao si predaleko od Posla te je Posao prekinut!", 3000)
            end
        end
        Citizen.Wait(1337)
    end
end)

Citizen.CreateThread(function()
    while true do
        if BlizuPosla == true then
            if AktiviranPosao == false then
                NapisiText("~COLOR_PURE_WHITE~Pritisni [~COLOR_YELLOW~" .. Config.Posao.DugmeTekst .. "~COLOR_PURE_WHITE~] da pokrenes Posao.", 0.5, 0.9, 0.7, 0.7, true, 255, 255, 255, 255, true)
                if IsControlJustPressed(0, Config.Posao.Dugme) then
                    AktivirajPosao()
                    Citizen.Wait(3000)
                end
            else
                NapisiText("~COLOR_PURE_WHITE~Pritisni [~COLOR_YELLOW~" .. Config.Posao.DugmeTekst .. "~COLOR_PURE_WHITE~] da prekines Posao.", 0.5, 0.9, 0.7, 0.7, true, 255, 255, 255, 255, true)
                if IsControlJustPressed(0, Config.Posao.Dugme) then
                    PrekiniPosao()
                    TriggerEvent("vorp:TipBottom", "Prekinuo si Posao!", 3000)
                    Citizen.Wait(3000)
                end
            end
        Citizen.Wait(7)
        else
            Citizen.Wait(1337)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if AktiviranPosao == true and BrojObjekata > 0 then
            NajbliziObjekt = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 1.37, GetHashKey(Config.Posao.Objekt), false, false, false)
            for Index = 1, #Config.Objekti, 1 do
                if PosaoObjekt[Index] == NajbliziObjekt then
                    if PorukaPokazana == false then NapisiText("~COLOR_PURE_WHITE~Pritisni [~COLOR_YELLOW~" .. Config.Posao.DugmeTekst .. "~COLOR_PURE_WHITE~] da Poravnas Travu.", 0.5, 0.9, 0.7, 0.7, true, 255, 255, 255, 255, true) end
                    if IsControlJustPressed(0, Config.Posao.Dugme) then
                        PorukaPokazana = true
                        if IsPedMale(PlayerPedId()) then
                            TaskStartScenarioInPlace(PlayerPedId(), GetHashKey(Config.Posao.MuskaAnimacija), -1, 1, 0, 0, 0)
                        else
                            TaskStartScenarioInPlace(PlayerPedId(), GetHashKey(Config.Posao.ZenskaAnimacija), -1, 1, 0, 0, 0)
                        end
                        FreezeEntityPosition(PlayerPedId(), true)
                        TriggerEvent("vorp:TipBottom", "Ravnas Travu...", 3000)
                        Citizen.Wait(15000)
                        PorukaPokazana = false
                        ClearPedTasksImmediately(PlayerPedId())
                        FreezeEntityPosition(PlayerPedId(), false)
                        DeleteEntity(PosaoObjekt[Index])
                        RemoveBlip(PosaoBlip[Index])
                        BrojObjekata = BrojObjekata - 1
                        if BrojObjekata == 0 then
                            TriggerServerEvent("j0le_kosactrave:server:Nagradi")
                            PrekiniPosao()
                        else
                            TriggerEvent("vorp:TipBottom", "Poravnao si Travu! Kreni dalje!", 3000)
                        end
                    end
                end
            end
        Citizen.Wait(7)
        else
            Citizen.Wait(1337)
        end
    end
end)

function AktivirajPosao()
    AktiviranPosao = true
    for Index = 1, #Config.Objekti, 1 do
        PosaoObjekt[Index] = CreateObject(GetHashKey(Config.Posao.Objekt), Config.Objekti[Index].X, Config.Objekti[Index].Y, Config.Objekti[Index].Z, false, false, true, false, false)
        PosaoBlip[Index] = N_0x554d9d53f696d002(1664425300, Config.Objekti[Index].X, Config.Objekti[Index].Y, Config.Objekti[Index].Z)
        SetBlipSprite(PosaoBlip[Index], Config.Posao.IkonaObjekta, 1)
        Citizen.InvokeNative(0x9CB1A1623062F402, PosaoBlip[Index], Config.Posao.ImeObjekta) 
        FreezeEntityPosition(PosaoObjekt[Index], true)
        BrojObjekata = BrojObjekata + 1
    end
    TriggerEvent("vorp:TipBottom", "Pokrenuo si Posao! Idi Poravnaj Travu!", 3000)
end

function PrekiniPosao()
    AktiviranPosao = false
    for Index = 1, #Config.Objekti, 1 do
        if DoesEntityExist(PosaoObjekt[Index]) then
            DeleteEntity(PosaoObjekt[Index])
            RemoveBlip(PosaoBlip[Index])
            if BrojObjekata > 0 then BrojObjekata = 0 end
        end
    end
end 

function NapisiText(String, X, Y, W, H, Sjena, Crvena, Zelena, Plava, Alpha, Centar)
    String = CreateVarString(10, "LITERAL_STRING", String)
    SetTextScale(W, H)
    SetTextColor(math.floor(Crvena), math.floor(Zelena), math.floor(Plava), math.floor(Alpha))
    SetTextCentre(Centar)
    if Sjena then SetTextDropshadow(1, 0, 0, 0, 255) end
    Citizen.InvokeNative(0xADA9255D, 1);
    DisplayText(String, X, Y)
end

AddEventHandler("playerDropped", function()
    RemoveBlip(Blip)
    if AktiviranPosao == true then
        for Index = 1, #Config.Objekti, 1 do
            if DoesEntityExist(PosaoObjekt[Index]) then
                DeleteEntity(PosaoObjekt[Index])
                RemoveBlip(PosaoBlip[Index])
                if BrojObjekata > 0 then BrojObjekata = 0 end
            end
        end
    end
end)

AddEventHandler("onResourceStop", function(ImeResourcea)
    if ImeResourcea == GetCurrentResourceName() then
        RemoveBlip(Blip)
        if AktiviranPosao == true then
            for Index = 1, #Config.Objekti, 1 do
                if DoesEntityExist(PosaoObjekt[Index]) then
                    DeleteEntity(PosaoObjekt[Index])
                    RemoveBlip(PosaoBlip[Index])
                end
            end
            if BrojObjekata > 0 then BrojObjekata = 0 end
        end
    end
end)