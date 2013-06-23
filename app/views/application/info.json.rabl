object @info => :server_info
attributes :track_count, :image_count, :server_time, :server_version
child(:jobs => :jobs) do
  attribute :id
  attribute :name
  attribute :args
  attribute :priority
  attribute :run_at
end

child(:sources => :sources) do
  attribute :id
  attribute :location
  attribute :last_scanned_at
  attribute :source_type
end
