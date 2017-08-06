require 'csv'
require Rails.root.join('app', 'services', 'word_recommender').to_s

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  WORDS = %w(CATASTROPHE HURRICANE SHOT BULLET DROWN ROBBER ABDUCTION HOSTAGE SHOTGUN DETONATE AMPUTATE
             SNIPER GRENADE TORNADO SEVERED PREDATOR INTRUDER MISSILE HIJACK PISTOL DISMEMBER CRUCIFY
             FIRE DISASTER RIFLE TUMOR GUN TOXIC EVIL THREATENED MADMAN MUGGING TRAUMA REVOLVER MUTILATE
             RIOT EXPLOSION STRANGLE RABIES BRUTALLY LETHAL ASSASSIN VENOM CRIME DEATHBED TERROR DEAD
             PARALYZE DANGER WEAPON CRASH ACCIDENT BRUTAL INCURABLE GUILLOTINE).freeze
  def index
    @words = WORDS
  end

  def create
    words_with_values = WORDS.select { |word| params[word].present? }
    @ratings = params.slice(*words_with_values)
    @result = WordRecommender.new(@ratings).recommended_words
  end
end
