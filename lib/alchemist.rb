require File.expand_path('../alchemist/unit', __FILE__)
require File.expand_path('../alchemist/definition', __FILE__)
# require 'alchemist/unit'
# require 'alchemist/definition'

module Alchemist

  def self.definition(name)
    definitions[name]
  end

  def self.define(measurement, &block)
    transmutator = Alchemist::Transmutator.new(measurement)
    transmutator.instance_eval(&block) if block
    transmutator.definitions.each do |definition|
      Alchemist.create_measurements(definition)
      Alchemist.create_measurement_methods(definition)
    end
  end

  def self.create_measurement_methods(definition)
    definition.each_name do |name|
      define_method name, proc{ Alchemist::Unit.new(definition, self) }
    end
  end

  def self.create_measurements(definition)
    definition.each_name do |name|
      definitions[name] = definition
    end
  end

  class Transmutator
    attr_accessor :definitions
    def initialize(measurement)
      @measurement = measurement
      @definitions = []
    end

    def unit(name, value, &block)
      definition = Alchemist::Definition.new(@measurement, name, value)
      definition.instance_eval(&block) if block
      @definitions << definition
    end
  end

  private

  def self.definitions
    @definitions ||= {}
  end

end

# Attach Alchemist
Numeric.send(:include, Alchemist)
