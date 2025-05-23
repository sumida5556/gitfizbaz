class Character
  attr_accessor :name, :hp, :attack, :alive, :type, :status

  def initialize(name, hp, attack, type = :player)
    @name = name
    @hp = hp
    @attack = attack
    @alive = true
    @type = type
    @status = nil
  end

  def take_damage(damage)
    @hp -= damage
    @hp = 0 if @hp < 0
    @alive = false if @hp <= 0
  end

  def heal(amount)
    @hp += amount
    puts "#{@name}の体力が #{amount} ポイント回復！（現在のHP：#{@hp}）"
  end

  def display_status
    mark = @alive ? "・" : "×"
    puts "#{mark}【#{@name}】 HP：#{@hp} 攻撃力：#{@attack}"
  end

  def can_act?
    return false unless @alive
    if @status == :paralyzed
      if rand < 0.5
        puts "#{@name}はマヒして動けない！"
        return false
      end
    end
    true
  end

  def reset
    @hp = 30
    @alive = true
    @status = nil
  end
end

def select_target(enemies)
  alive = enemies.select(&:alive)
  alive.empty? ? nil : alive.sample
end

def generate_random_enemies
  templates = [
    { name: "オーク", hp: 20, attack: 8 },
    { name: "ゴブリン", hp: 18, attack: 6 },
    { name: "スライム", hp: 12, attack: 4 },
    { name: "コボルト", hp: 16, attack: 5 }
  ]
  num = rand(1..4)
  enemies = []
  num.times do
    t = templates.sample
    enemies << Character.new(t[:name], t[:hp], t[:attack], :enemy)
  end
  enemies
end

def battle(player, party, enemies)
  loop do
    puts "\nキャラクターの現在の状態："
    (party + enemies).each(&:display_status)

    puts "\n▼ 行動を選んでください ▼"
    puts "【1】攻撃\n【2】回復する\n【3】逃げる"
    action = gets.to_i

    case action
    when 1
      puts "#{player.name} の攻撃！"
      if rand < 0.2
        puts "→ しかし攻撃は空振りだった！"
      else
        if rand < 0.2
          puts "→奥義『サンダーソード』が発動！"
          enemies.each do |enemy|
            if enemy.alive
              puts "→#{enemy.name} に 10 のダメージ！"
              enemy.take_damage(10)
            end
          end
        else
          target = select_target(enemies)
          if target
            damage = player.attack
            puts "→#{target.name} に #{damage} のダメージ！"
            target.take_damage(damage)
          end
        end
      end
    when 2
      heal_amount = 10
      puts "#{player.name}は回復呪文を唱えた！"
      player.heal(heal_amount)
    when 3
      puts "#{player.name}は戦いを避けた！"
      return
    else
      puts "無効な入力です。もう一度選んでください。"
    end

    party[1..].each do |member|
      next unless member.can_act?
      puts "#{member.name}の魔法攻撃！"
      if rand < 0.2
        puts "→呪文に失敗してしまった！"
        damage = 2
      else
        damage = member.attack + rand(5..10)
      end
      target = select_target(enemies)
      if target
        puts "→#{target.name} に #{damage} ダメージ！"
        target.take_damage(damage)
        if rand < 0.3
          puts "→#{target.name} はマヒ状態になった！"
          target.status = :paralyzed
        end
      end
    end

    if enemies.none?(&:alive)
      puts "\n◆◆◆ 勝利を収めた！ ◆◆◆"
      break
    end

    puts "\n敵の反撃フェーズ！"
    enemies.each do |enemy|
      next unless enemy.can_act?
      target = party.select(&:alive).sample
      if rand < 0.2
        puts "#{enemy.name}の攻撃！ →ミス！"
      else
        damage = enemy.attack
        puts "#{enemy.name} の攻撃！→#{target.name} に #{damage} ダメージ！"
        target.take_damage(damage)
      end
    end

    if party.none?(&:alive)
      puts "\n◆◆◆ ゲームオーバー ◆◆◆"
      puts "\nもう一度挑戦しますか？\n【1】はい\n【2】いいえ"
      choice = gets.to_i
      if choice == 1
        party.each(&:reset)
        enemies = generate_random_enemies
        puts "\n◆◆◆ 新たなモンスターが現れた！ ◆◆◆"
        next
      else
        break
      end
    end
  end
end

# ゲームスタート
puts "勇者の名前を教えてください："
hero_name = gets.chomp
player = Character.new(hero_name, 30, 8)
wizard = Character.new("魔法使い", 20, 10)
party = [player, wizard]

enemies = generate_random_enemies

puts "\n◆◆◆ モンスターが出現！ ◆◆◆"
battle(player, party, enemies)
