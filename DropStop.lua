_addon.name = 'Drop Stop'
_addon.author = 'Dean James (Xurion of Bismarck)'
_addon.commands = {'dropstop', 'ds'}
_addon.version = '0.0.1'

packets = require('packets')
items = require('resources').items
config = require('config')

defaults = {
    items = ''
}
settings = config.load(defaults)

default_protected_items = require('defaults')
custom_protected_items = T{}

if string.len(settings.items) > 0 then
    for item in settings.items:gmatch("([^,]+)") do
        table.insert(custom_protected_items, item)
    end
end

protected_items = T{}

for k, v in ipairs(default_protected_items) do
    table.insert(protected_items, v:lower())
end
for k, v in ipairs(custom_protected_items) do
    table.insert(protected_items, v:lower())
end

function save_settings()
    settings.items = table.concat(custom_protected_items, ",")
    settings:save()
end

windower.register_event('outgoing chunk', function(id, data)
    if id == 0x028 then --drop item packet
        local parsed = packets.parse('outgoing', data)
        local item = windower.ffxi.get_items(0, parsed['Inventory Index'])
        if protected_items:contains(items[item.id].name:lower()) then
            windower.add_to_chat(8, 'Drop Stop prevented you dropping ' .. items[item.id].name)
            return true --prevent the drop
        end
    end
end)

windower.register_event('addon command', function(command, ...)
    local item_parts = {...}
    if #item_parts == 0 then return end

    local item_name = table.concat(item_parts, " ")
    local item_name_lower = item_name:lower()

    if command == 'add' and not custom_protected_items:contains(item_name_lower) then
        table.insert(custom_protected_items, item_name_lower)
        table.insert(protected_items, item_name_lower)
        save_settings()
        windower.add_to_chat(8, 'Drop Stop will now prevent you from dropping ' .. item_name)
    elseif command == 'remove' then
        custom_protected_items:delete(item_name)
        protected_items:delete(item_name)
        save_settings()
        windower.add_to_chat(8, 'Drop Stop will no longer prevent you from dropping ' .. item_name)
    end
end)
