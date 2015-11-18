defimpl Collectable, for: UnshorteningPool do
  def into(%UnshorteningPool{}), do:
    UnshorteningPool.Mapper.into(UnshorteningPool.pool_name)
end
