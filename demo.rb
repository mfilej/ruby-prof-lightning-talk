#!/usr/bin/env ruby
require "bundler/setup"

# +++
require "ruby-prof"
# +++

# What if we move hashing into Person class to show how the profiling result
# changes?

require "bcrypt"

class Auth
  HASHING_COST = 6

  def collect(people)
    Hash[
      people.map { |(name, pass)|
        hash = compute_password_hash(pass)
        [name, Person.new(name: name, hash: hash)]
      }
    ]
  end

  private

  def compute_password_hash(pass)
    BCrypt::Password.create(pass, cost: HASHING_COST)
  end
end

class Person
  attr_reader :user, :hash, :pass

  def initialize(name:, hash:)
    @name = name
    @hash = hash
    @pass = BCrypt::Password.new(hash)
  end
end

class Program
  def _run
    credentials = [
      ["Alex", "password1"],
      ["Brook", "password2"],
      ["Corey", "password3"],
      ["Drew", "password4"],
      ["Elliott", "password5"],
      ["Frances" "password6"],
    ] * 99
    people = Auth.new.collect(credentials)
    credentials.each do |(name, pass)|
      person = people.fetch(name)
      if person.pass == pass
        puts "Authenticated"
      end
    end
  end

  def run
    # +++
    result = RubyProf.profile do
    # +++

      _run

    # +++
    end
    printer = RubyProf::GraphHtmlPrinter.new(result)
    File.open("result.html", "w") do |file| printer.print(file) end
    # +++
  end
end

Program.new.run
