require_relative "developer"
require_relative "junior"
require_relative "senior"

class Team
  attr_reader :seniors
              :developers
              :juniors
  attr_accessor :team



  def initialize(&block)
    @team = {}
    @on_task = {}
    instance_eval &block
  end

  private

  def have_seniors(*names)
    @seniors = names.map{|name| SeniorDeveloper.new(name)}
    @team[:seniors] = @seniors
  end

  def have_developers(*names)
    @developers = names.map{|name| Developer.new(name)}
    @team[:developers] = @developers
  end

  def have_juniors(*names)
    @juniors = names.map{|name| JuniorDeveloper.new(name)}
    @team[:juniors] = @juniors
  end

  def priority(*args)
    @priority = args
  end

  def on_task(key, &block)
    @on_task[key] = block
  end 

  def free_dev(devs)
    devs.min_by{|dev| dev.task_list.count}
  end

  public

  def add_task(task, options = {})
    if name = options[:to]
      if required_dev = all.find{|dev| dev.name == name}
        required_dev.add_task(task)
      else
        puts "Такой разработчик не найден"
      end
      return
    end

    if type = options[:complexity]
      if required_type = all.find{|dev| dev.type == type}
        free_dev(@team["#{type.to_s}s".to_sym]).add_task(task)
      else
        puts "Нет разработчиков с таким уровнем сложности"
      end
      return
    end

    @priority.each do |type|
      dev = free_dev(@team[type])
      if dev.can_add_task?
        dev.add_task(task)
        if @on_task[dev.type]
          @on_task[dev.type].call(dev, task)
        end
      return
      end
    end
  end


  def seniors
    @seniors
  end

  def developers
    @developers
  end

  def juniors
    @juniors
  end

  def all
    @team.values.flatten
  end

  def report
    report_list = all.sort_by do |dev|
      [dev.can_add_task? ? 0 : 1,
        @priority.index("#{dev.type.to_s}s".to_sym),
        dev.task_list.length]
    end
    report_list.each{|dev| puts "#{dev.name} (#{dev.type.to_s}): #{dev.task_list.join","}"}
  end


end
