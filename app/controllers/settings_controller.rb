class SettingsController < ApplicationController
  include AppConfig::Processor
  def index
    respond_to do |format|
      format.json { render json: AppConfig.reload }
    end
  end

  def update
    params.each do |key, value|
      key = key.downcase.to_sym
      next if [:controller, :action, :format].include?(key)

      setting = Setting.where(keyname: key).first_or_create
      # don't add new keys
      unless setting.id.nil?
        value = deserialize(value, setting.value_format)
        AppConfig[key.to_sym] = value
      end
    end

    AppConfig.save
    respond_to do |format|
      format.json { render json: AppConfig.reload }
    end
  end

end
