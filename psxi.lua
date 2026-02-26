addon.name    = 'psxi';
addon.author  = 'Hanayaka';
addon.version = '1.0';
addon.desc    = 'Copies a deduplicated JSON list of all owned equipment to the clipboard.';
addon.link    = 'https://ashitaxi.com/';

require('common');
local json = require('json');
local slips = require('slips');

local inventory = AshitaCore:GetMemoryManager():GetInventory();
local resources = AshitaCore:GetResourceManager();

local STORAGES = {
    { id=0,  name='Inventory' },
    { id=1,  name='Safe' },
    { id=2,  name='Storage' },
    { id=3,  name='Temporary' },
    { id=4,  name='Locker' },
    { id=5,  name='Satchel' },
    { id=6,  name='Sack' },
    { id=7,  name='Case' },
    { id=8,  name='Wardrobe' },
    { id=9,  name='Safe 2' },
    { id=10, name='Wardrobe 2' },
    { id=11, name='Wardrobe 3' },
    { id=12, name='Wardrobe 4' },
    { id=13, name='Wardrobe 5' },
    { id=14, name='Wardrobe 6' },
    { id=15, name='Wardrobe 7' },
    { id=16, name='Wardrobe 8' },
};

local function bit(p)
    return 2 ^ (p - 1);
end

local function hasBit(x, p)
    return x % (p + p) >= p;
end

local function run()
    local seen = {};
    local results = {};
    local storageSlips = {};

    -- Scan all containers for equipment and collect storage slips
    for _, v in ipairs(STORAGES) do
        for j = 0, inventory:GetContainerCountMax(v.id), 1 do
            local itemEntry = inventory:GetContainerItem(v.id, j);
            if (itemEntry.Id ~= 0 and itemEntry.Id ~= 65535) then
                local res = resources:GetItemById(itemEntry.Id);
                if (res ~= nil) then
                    if (res.Slots ~= nil and res.Slots ~= 0) then
                        if (seen[itemEntry.Id]) then
                            results[seen[itemEntry.Id]].count = results[seen[itemEntry.Id]].count + 1;
                        else
                            results[#results + 1] = { id = itemEntry.Id, name = res.Name[1], count = 1 };
                            seen[itemEntry.Id] = #results;
                        end
                    end

                    if (slips.items[itemEntry.Id] ~= nil) then
                        storageSlips[#storageSlips + 1] = itemEntry;
                    end
                end
            end
        end
    end

    -- Scan storage slips for stored equipment
    for _, slip in ipairs(storageSlips) do
        local slipItems = slips.items[slip.Id];
        local extra = slip.Extra;

        for i, slipItemId in ipairs(slipItems) do
            if (slipItemId ~= 0) then
                local byte = struct.unpack('B', extra, math.floor((i - 1) / 8) + 1);
                if (byte < 0) then byte = byte + 256; end

                if (hasBit(byte, bit((i - 1) % 8 + 1))) then
                    local res = resources:GetItemById(slipItemId);
                    if (res ~= nil and res.Slots ~= nil and res.Slots ~= 0) then
                        if (seen[slipItemId]) then
                            results[seen[slipItemId]].count = results[seen[slipItemId]].count + 1;
                        else
                            results[#results + 1] = { id = slipItemId, name = res.Name[1], count = 1 };
                            seen[slipItemId] = #results;
                        end
                    end
                end
            end
        end
    end

    -- Copy results to clipboard
    local output = json.encode(results);
    if (ashita.misc.set_clipboard(output)) then
        print(('\30\08[psxi] Copied %d equipment items to clipboard.'):fmt(#results));
    else
        print('\30\08[psxi] Failed to copy to clipboard.');
    end
end

ashita.events.register('command', 'psxi_command_cb', function(e)
    local args = e.command:args();
    if (#args < 2 or args[1]:lower() ~= '/psxi' or args[2]:lower() ~= 'export') then
        return;
    end
    e.blocked = true;
    run();
end);
