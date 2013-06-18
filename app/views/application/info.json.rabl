object @info => :server_info
attributes :track_count, :image_count, :server_time
child(:jobs => :jobs) do
  attribute :id
  attribute :name
  attribute :args
  attribute :priority
  attribute :run_at
end
