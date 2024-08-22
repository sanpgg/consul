class Budget
  class Result

    attr_accessor :budget, :heading, :sector, :money_spent, :current_investment

    def initialize(budget, heading, sector = nil)
      @budget = budget
      @heading = heading
      @sector = sector
    end

    def calculate_winners_v2

      puts "Propuestas factibles del sector #{sector}: #{investments_v2.count}"

      reset_winners_v2

      # Recorrer los tamaños
      larges = investments_v2.compatible.by_size("large")
      mediums = investments_v2.compatible.by_size("medium")

      puts "Hay #{larges.count} propuestas grandes (12.5 MDP) factibles del sector #{sector}"
      puts "====="

      # Grandes
      set_large_winners(larges)
      # larges.each do |large|
      # end

      puts "====="

      puts "Hay #{mediums.count} propuestas medianas (1 MDP) factibles del sector #{sector}"

      # Medianas
      # mediums.each do |medium|
      #   puts "Propuesta mediana: #{medium.id} → Votos online: #{Budget::Ballot::Line.counter(medium.id)} + Votos offline: #{medium.ballot_offline_count}"
      # end

      set_medium_winners(mediums)

      puts "========="

    end

    def set_large_winners(larges)
      return if larges.blank? # Verifica si `larges` está vacío o es `nil`
    
      first_large = larges.first
      return if first_large.nil? # Verifica si el primer elemento es `nil`
    
      max_votes = first_large.total_votes_v2
      return if max_votes.nil? # Verifica si `total_votes_v2` es `nil`
    
      winning_projects = larges.select { |investment| investment.total_votes_v2 == max_votes }
    
      if winning_projects.size > 1
        # Hay un empate
        winning_projects.each { |investment| investment.update(draw: true) }
      else
        # Hay un ganador
        winning_projects.first.update(winner: true)
      end
    end
    

    def set_medium_winners(mediums)

      online_votes = {}
      
      Budget::Investment.get_online_votes.each do |row|
        #puts "#{row["investment_id"]} → #{row["total_online_votes"]}"
        online_votes[row["investment_id"]] = row["total_online_votes"]
      end

      #puts online_votes.inspect

      results = mediums.map do |bi|
        total_votes = bi.ballot_offline_count + (online_votes[bi.id.to_s].to_i || 0)

        #puts "Total = #{bi.id} → #{bi.ballot_offline_count} + #{(online_votes[bi.id] || 0)} = #{total_votes}"

        {
          id: bi.id,
          title: bi.title,
          total_votes_v10: total_votes
        }
      end
      
      sorted_results = results.sort_by { |r| -r[:total_votes_v10] }

      sorted_results.each do |i|
        puts "#{i[:id]} → #{i[:total_votes_v10]}"
      end

      puts "------------------------------------------"

      # Si hay menos de 10 propuestas, todas son ganadoras
      if mediums.size <= 10
        mediums.each { |investment| investment.update(winner: true) }
        return
      end
    
      # Encontrar el índice del primer proyecto que está empatado
      # tenth_place_votes = mediums[9].total_votes_v2
      tenth_place_votes = sorted_results[9][:total_votes_v10]

      puts "=== AFTER"
      puts "Primeros 15 votos: #{mediums.first(15).map(&:total_votes_v2)}"
      puts "Primeros 15 votos: #{mediums.first(15).map(&:id)}"
      puts "=== BEFORE"
      puts "Primeros 15 votos: #{sorted_results.first(15).map { |item| item[:total_votes_v10] }.join(', ')}"
      puts "Primeros 15 votos: #{sorted_results.first(15).map { |item| item[:id] }.join(', ')}"
      puts "==="

      puts "Votos de la décima posición: #{tenth_place_votes}"

      draw_count_10 = sorted_results.select { |investment| investment[:total_votes_v10] == tenth_place_votes }.size

      puts "Cantidad de propuestas empatadas en la posición 10: #{draw_count_10}"

      if draw_count_10 == 1
        sorted_results[0...10].each do |investment|
          #investment.update(winner: true)
          Budget::Investment.find_by(id: investment[:id]).update(winner: true)
          puts "Ganadora segura: #{investment[:id]} → #{investment[:total_votes_v10]}"
        end

        return
      end

      # Si pasa hasta aquí es porque hay empates

      first_draw_index = sorted_results.index { |investment| investment[:total_votes_v10] == tenth_place_votes }

      if sorted_results[0...first_draw_index].size + draw_count_10 == 10
        # Si las ganadoras seguras más las empatadas en la posición 10 son 10
        # Entonces las empatadas son también ganadoras

        sorted_results[0...10].each do |investment|
          #investment.update(winner: true)
          Budget::Investment.find_by(id: investment[:id]).update(winner: true)
          puts "Ganadora segura con empate al final: #{investment[:id]} → #{investment[:total_votes_v10]}"
        end

        return
      end
    
      # Marcar como ganadoras las primeras n - 1 propuestas
      sorted_results[0...first_draw_index].each do |investment|
        #investment.update(winner: true)
        Budget::Investment.find_by(id: investment[:id]).update(winner: true)
        puts "Ganadora segura: #{investment[:id]} → #{investment[:total_votes_v10]}"
      end

      # Marcar como empate las propuestas que tienen los mismos votos que la primera propuesta empatada
      draws = sorted_results.select { |investment| investment[:total_votes_v10] == tenth_place_votes }
      
      draws.each do |investment|
        #investment.update(draw: true)
        Budget::Investment.find_by(id: investment[:id]).update(draw: true)
        puts "Empatada: #{investment[:id]} → #{investment[:total_votes_v10]}"
      end

      # # Marcar como empate las propuestas empatadas
      # mediums[first_draw_index..-1].each do |investment|
      #   investment.update(draw: true)
      #   puts "Empatada: #{investment.id} → #{investment.total_votes_v2}"
      # end

      puts "------------------------------------------"
    end
    
    def calculate_winners
      reset_winners
      investments.compatible.each do |investment|
        @current_investment = investment
        set_winner if inside_budget?
      end 
    end

    def investments_v2
      budget.investments.selected.by_sector_v2(User.sector.find_value(sector).value).sort_by_ballots
    end

    def investments
      heading.investments.selected.sort_by_ballots
    end

    def inside_budget?
      available_budget >= @current_investment.price
    end

    def available_budget
      total_budget - money_spent
    end

    def total_budget
      heading.price
    end

    def money_spent
      @money_spent ||= 0
    end

    def reset_winners
      investments.update_all(winner: false)
    end

    def reset_winners_v2
      investments_v2.update_all(winner: false, draw: nil)
    end

    def set_winner

      #total = @current_investment.ballot_offline_count + @current_investment.ballot_lines_count
      total = @current_investment.ballot_offline_count + Budget::Ballot::Line.counter(current_investment.id)

      if total >= 10
        @money_spent += @current_investment.price
        @current_investment.update(winner: true)
      end
    end

    def winners
      investments.where(winner: true)
    end

  end
end
