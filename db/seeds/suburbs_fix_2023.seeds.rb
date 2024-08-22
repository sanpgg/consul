puts "=== SUBURBS"

fix = [
    { id: 206, name: 'Bosques del Valle 5to Sector', old_sector: 'K2', new_sector: 'K3' },
    { id: 207, name: 'El Refugio', old_sector: 'K2', new_sector: 'K6' },
    { id: 208, name: 'Hacienda del Valle', old_sector: 'K2', new_sector: 'K3' },
    { id: 210, name: 'Hacienda San Agustín', old_sector: 'K2', new_sector: 'K6' },
    { id: 215, name: 'La Muralla', old_sector: 'K2', new_sector: 'K6' },
    { id: 220, name: 'Lucio Blanco 3er Sector', old_sector: 'K2', new_sector: 'K1' },
    { id: 221, name: 'Mirador del Campestre', old_sector: 'K2', new_sector: 'K6' },
    { id: 236, name: 'Balcones del Campestre', old_sector: 'K3', new_sector: 'K6' },
    { id: 239, name: 'Bosques de San Pedro', old_sector: 'K3', new_sector: 'K2' },
    { id: 244, name: 'Del Valle Oriente', old_sector: 'K3', new_sector: 'K4' },
    { id: 245, name: 'Jardines del Valle', old_sector: 'K3', new_sector: 'K4' },
    { id: 246, name: 'Lomas del Rosario', old_sector: 'K3', new_sector: 'K2' },
    { id: 345, name: 'Ampliación Lomas del Valle', old_sector: 'K3', new_sector: 'K6' },
    { id: 258, name: 'Calendas', old_sector: 'K4', new_sector: 'K2' },
    { id: 259, name: 'Cortijo del Valle', old_sector: 'K4', new_sector: 'K3' },
    { id: 260, name: 'Del Valle Sector Fátima', old_sector: 'K4', new_sector: 'K3' },
    { id: 261, name: 'El Secreto', old_sector: 'K4', new_sector: 'K6' },
    { id: 265, name: 'La Barranca', old_sector: 'K4', new_sector: 'K3' },
    { id: 271, name: 'Privada Lomas de San Agustín', old_sector: 'K4', new_sector: 'K6' },
    { id: 276, name: 'Vista Real', old_sector: 'K4', new_sector: 'K6' },
    { id: 309, name: 'Zona Lomas de San Agustín', old_sector: 'K5', new_sector: 'K6' },
    { id: 281, name: 'Antigua Hacienda San Agustín', old_sector: 'K5', new_sector: 'K6' },
    { id: 315, name: 'Colonial de la Sierra', old_sector: 'K6', new_sector: 'K3' },
    { id: 317, name: 'El Obispo', old_sector: 'K6', new_sector: 'K1' },
    { id: 319, name: 'La Diana', old_sector: 'K6', new_sector: 'K4' },
    { id: 320, name: 'La Ventura', old_sector: 'K6', new_sector: 'K2' },
    { id: 323, name: 'Lomas de Tampiquito', old_sector: 'K6', new_sector: 'K3' },
    { id: 324, name: 'Lomas del Valle', old_sector: 'K6', new_sector: 'K3' },
    { id: 325, name: 'Los Pinos 2do Sector', old_sector: 'K6', new_sector: 'K1' },
    { id: 376, name: 'De Las Alondras', old_sector: 'K5', new_sector: 'K6' },
    { id: 414, name: 'Mirasierra 2do Sector', old_sector: 'K3', new_sector: 'K2' },
    { id: 415, name: 'Mirasierra 3er Sector', old_sector: 'K4', new_sector: 'K2' },
    { id: 416, name: 'Mirasierra 4to Sector', old_sector: 'K5', new_sector: 'K2' },
    { id: 417, name: 'Mirasierra 5to Sector', old_sector: 'K6', new_sector: 'K2' },
    { id: 497, name: 'Zona Colinas de la Sierra Madre', old_sector: 'K1', new_sector: 'K3' },
    { id: 503, name: 'Zona Exhacienda San Agustín', old_sector: 'K6', new_sector: 'K5' },
    { id: 187, name: 'Jerónimo Siller', old_sector: 'K1', new_sector: 'K3' },
    { id: 188, name: 'Los Olmos', old_sector: 'K1', new_sector: 'K2' },
    { id: 190, name: 'Los Sauces 2do Sector', old_sector: 'K1', new_sector: 'K2' }
]

fix.each do |f|
    suburb = Colonium.find(f[:id])

    puts "#{f[:id]} | Old sector: #{suburb.sector} | New sector: #{f[:new_sector]}"

    suburb.sector = f[:new_sector]

    if suburb.save
        puts "#{f[:name]} updated!"
    else
        puts "#{f[:name]} update failed! <<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    end
end

users = [
    { id: 13164, old_sector: 6 },
    { id: 13166, old_sector: 4 },
    { id: 13168, old_sector: 6 },
    { id: 13186, old_sector: 1 },
    { id: 13193, old_sector: 3 },
    { id: 13197, old_sector: 2 },
    { id: 13198, old_sector: 6 },
    { id: 13199, old_sector: 6 },
    { id: 13201, old_sector: 6 },
    { id: 13214, old_sector: 4 },
    { id: 13224, old_sector: 3 },
    { id: 13225, old_sector: 3 },
    { id: 13226, old_sector: 6 },
    { id: 13230, old_sector: 3 },
    { id: 13235, old_sector: 3 },
    { id: 13238, old_sector: 3 }
]

puts "======"
puts "=== USERS"

users.each do |u|

    user = User.find(u[:id])

    new_sector = user.colonium.first.sector

    puts "#{u[:id]} | Old sector: #{user.sector} | New sector: #{new_sector}"

    user.sector = new_sector

    if user.save
        puts "#{u[:id]} updated!"
    else
        puts "#{u[:id]} failed! <<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    end
end

puts "======"