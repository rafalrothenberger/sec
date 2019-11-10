defmodule Sec.NifTest do

  def run() do
    g = '1 3685416753713387016781088315183077757961620795782546409894578378688607592378376318836054947676345821548104185464507 1339506544944476473020471379941921221584933875938349620426543736416511423956333506472724655353366534992391756441569'
    scalar = '5'

    start = DateTime.utc_now()

    BlsNif.Nif.nif_g1mul(g, scalar)

    stop = DateTime.utc_now()

    t = DateTime.to_unix(stop, :microsecond) - DateTime.to_unix(start, :microsecond)

    IO.puts("Time: #{t}us")
  end

end
