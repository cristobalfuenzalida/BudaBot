# frozen_string_literal: true

require 'byebug'
require 'date'
require 'highline/import'
require 'http'
require 'json'

# Function to obtain the average value of an array
def mean(array)
  array.sum(0.0) / array.size
end

# Function to iterate over market data to show its relevant information
# data: corresponds to a json structure containing the needed markets data
# selection: corresponds to the type of value selection the user chose
# range: corresponds to the range of time in which data is filtered
def show_markets(data, selection, range = 'd')
  separator = '|____________________________________________________________|'\
              "\n|                                                            |"

  data.each do |market|
    if selection != 'i' # When info is selected, there's no need to filter data
      url = 'https://www.buda.com/api/v2'
      time = Time.now.to_i * 1000 # Timestamp representing the current time
      suffix = "/trades?timestamp=#{time}&limit=100"
      response = HTTP.get("#{url}/markets/#{market['id']}#{suffix}")
      if response.code == 200
        entries = JSON.parse(response)['trades']['entries']
        # The last date used to filter the data depends on the selected range
        # Notice that timestamps used by Buda are in miliseconds
        case range
        when 'd'
          last_date = time - 24 * 60 * 60 * 1000
        when 'w'
          last_date = time - 7 * 24 * 60 * 60 * 1000
        when 'm'
          last_date = time - 30 * 24 * 60 * 60 * 1000
        when 'a'
          last_date = 0
        end
        # Arrays to contain the samples to be used and shown
        filtered = []
        buy_values = []
        sell_values = []
        entries.map do |entry|
          next unless entry[0].to_i >= last_date

          filtered << entry
          case entry[3]
          when 'buy'
            buy_values << entry[1].to_f
          when 'sell'
            sell_values << entry[1].to_f
          end
        end
      else
        connection_error
      end
    end
    
    # Building of the blocks to be shown in each iteration for each market
    content_block = [
      "| ID:                        #{market['id']}",
      "| Name:                      #{market['name']}"
    ]

    case selection
    # When market info is selected, only its basic data is shown
    when 'i'
      content_block << "| Base Currency:             #{market['base_currency']}"
      content_block << "| Quote Currency:            #{market['quote_currency']}"
      content_block << '| Minimum Order Amount:      '\
                       "#{market['minimum_order_amount'][0]} "\
                       "(#{market['minimum_order_amount'][1]})"
    # When trades highest is selected, it calculates and shows said data
    when 'h'
      max_entry = filtered.max_by { |e| e[1] }
      max_time = Time.at(max_entry[0].to_i / 1000).utc.to_datetime
      max_time = max_time.strftime('%d/%m/%Y %I:%M:%S')
      max_value = max_entry[1]
      max_price = max_entry[2]
      max_direction = max_entry[3]
      content_block << "| Highest Transaction:       #{max_value} "\
                       "(#{market['base_currency']})"
      if market['quote_currency'] == 'CLP'
        eq_value = format('%0.2f', (max_value.to_f * max_price.to_f))
        content_block << "| --> Equivalent in CLP:     #{eq_value} (CLP)"
      end
      content_block << "| Transaction Direction:     #{max_direction}"
      content_block << "| Transaction Price:         #{max_price} "\
                       "(#{market['quote_currency']})"
      content_block << "| Transaction Date/Time:     #{max_time}"

    # When trades lowest is selected, it calculates and shows said data
    when 'l'
      min_entry = filtered.min_by { |e| e[1] }
      min_time = Time.at(min_entry[0].to_i / 1000).utc.to_datetime
      min_time = min_time.strftime('%d/%m/%Y %I:%M:%S')
      min_value = min_entry[1]
      min_price = min_entry[2]
      min_direction = min_entry[3]
      content_block << "| Lowest Transaction:        #{min_value} "\
                       "(#{market['base_currency']})"
      if market['quote_currency'] == 'CLP'
        eq_value = format('%0.2f', (min_value.to_f * min_price.to_f))
        content_block << "| --> Equivalent in CLP:     #{eq_value} (CLP)"
      end
      content_block << "| Transaction Direction:     #{min_direction}"
      content_block << "| Transaction Price:         #{min_price} "\
                       "(#{market['quote_currency']})"
      content_block << "| Transaction Date/Time:     #{min_time}"

    # When trades average is selected, it calculates and shows said data
    when 'm'
      content_block << "| Average Buy Value:         #{mean(buy_values)}"
      content_block << "| Average Sell Value:        #{mean(sell_values)}"
    end
    
    # Basic formatting of each line for design purposes
    puts separator
    content_block.each do |line|
      n = 61 - line.length
      if n >= 0
        new_line = line + ' ' * n + '|'
        puts new_line
      else
        puts line
      end
    end
  end
end

# Function to interact with the user in a menu fashion, prompts the user
# to choose between showing information or quit the program
def menu
  puts '|____________________________________________________________|'
  puts '|                                                            |'
  puts '| -- M E N U :                                               |'
  puts '|                                                            |'
  puts "| * Show :   's'                                             |"
  puts "| * Quit :   'q'                                             |"
  puts '|____________________________________________________________|'

  input = ''
  loop do
    puts ''
    input = ask '  >> '
    puts ''
    if ['q', 's'].include? input
      break
    else
      puts ' ____________________________________________________________ '
      puts '|                                                            |'
      puts '| Invalid input, please try again...                         |'
      puts '|____________________________________________________________|'
    end
  end
  input
end

# Function to work when the user chooses to show, it prompts the user
# to select the parameters for the program to show the wanted data
def selector
  puts ' ____________________________________________________________ '
  puts '| What do you want to show?:                                 |'
  puts '|                                                            |'
  puts "| * Markets Info            :   'i'                          |"
  puts "| * Markets Trades Highest  :   'h'                          |"
  puts "| * Markets Trades Lowest   :   'l'                          |"
  puts "| * Markets Trades Average  :   'm'                          |"
  puts '|____________________________________________________________|'

  input1 = ''

  loop do
    puts ''
    input1 = ask '  >> '
    puts ''
    if ['i', 'h', 'l', 'm'].include? input1
      break
    else
      puts ' ____________________________________________________________ '
      puts '|                                                            |'
      puts '| Invalid input, please try again...                         |'
      puts '|____________________________________________________________|'
    end
  end

  # If market info is selected, there's no need for a time range
  return input1, 'd' if input1 == 'i'

  # If the selection is not market info, the program prompts for a range
  # to be selected by the user
  puts ' ____________________________________________________________ '
  puts '| What time range do you want to use?:                       |'
  puts '|                                                            |'
  puts "| * Last 24 hours           :   'd'                          |"
  puts "| * Last 7 days             :   'w'                          |"
  puts "| * Last 30 days            :   'm'                          |"
  puts "| * All available           :   'a'                          |"
  puts '|____________________________________________________________|'

  input2 = ''

  loop do
    puts ''
    input2 = ask '  >> '
    puts ''
    if ['d', 'w', 'm', 'a'].include? input2
      break
    else
      puts ' ____________________________________________________________ '
      puts '|                                                            |'
      puts '| Invalid input, please try again...                         |'
      puts '|____________________________________________________________|'
    end
  end
  [input1, input2]
end

# Function to close the program and exit whenever it is needed
def leave
  puts ' ____________________________________________________________ '
  puts '|                                                            |'
  puts '| Sorry to see you leave...                                  |'
  puts '| Thank you for using Buda-Bot. See you soon!                |'
  puts '|____________________________________________________________|'
end

# Error showing method for the http protocol
def connection_error
  puts '|____________________________________________________________|'
  puts '|                                                            |'
  puts '| Error: Connection failed!                                  |'
  puts '|        Automatically quitting...                           |'
  puts '|____________________________________________________________|'
  leave
end

# Main function. Uses all other methods in order to keep an interaction with
# the user as longs as they want to. It prompts the user to choose their
# actions and shows all needed data from the markets based on user choices
def interactive
  url = 'https://www.buda.com/api/v2'
  response = HTTP.get("#{url}/markets")

  puts ' ____________________________________________________________ '
  puts '|                                                            |'
  puts '|          W E L C O M E    T O    B U D A - B O T!          |'

  if response.code == 200
    markets = JSON.parse(response)['markets']
    # The interaction is cointained in a conditional loop, it is maintained
    # as long as the user doesn't choose to quit.
    loop do
      input = menu

      case input
      when 'q'
        leave
        break
      # When showing is chosen, the program displays a message regarding the
      # information to be shown. 
      when 's'
        selection, time_range = selector
        case selection
        when 'i'
          puts ' ____________________________________________________________ '
          puts '|                                                            |'
          puts '| General information of all markets:                        |'
        when 'h'
          puts ' ____________________________________________________________ '
          puts '|                                                            |'
          puts '| Highest transactions of all markets:                       |'
        when 'l'
          puts ' ____________________________________________________________ '
          puts '|                                                            |'
          puts '| Lowest transactions of all markets:                        |'
        when 'm'
          puts ' ____________________________________________________________ '
          puts '|                                                            |'
          puts '| Mean of transactions of all markets:                       |'
        end
        if selection != 'i'
          # The program displays the time range selected for the information
          # to be shown.
          case time_range
          when 'd'
            puts '| Showing data from last 24 hours...                         |'
          when 'w'
            puts '| Showing data from last 7 days...                           |'
          when 'm'
            puts '| Showing data from last 30 days...                          |'
          when 'a'
            puts '| Showing from all available data...                         |'
          end
        end
        show_markets(markets, selection, time_range)
      end
    end
  else
    connection_error
  end
end

# Execution of the program
interactive
