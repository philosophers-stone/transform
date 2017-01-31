defmodule ErlRecords do
  @moduledoc """
  Helper functions for converting nested Erlang Record structures to Keyword lists.
  """

  import PhStTransform



# iex(2)> recs = Record.extract_all(from_lib: "kernel/src/inet_dns.hrl")
# [dns_header: [id: 0, qr: 0, opcode: 0, aa: 0, tc: 0, rd: 0, ra: 0, pr: 0,
#   rcode: 0],
#  dns_rec: [header: :undefined, qdlist: [], anlist: [], nslist: [], arlist: []],
#  dns_rr: [domain: [], type: :any, class: :in, cnt: 0, ttl: 0, data: [],
#   tm: :undefined, bm: [], func: false],
#  dns_rr_opt: [domain: [], type: :opt, udp_payload_size: 1280, ext_rcode: 0,
#   version: 0, z: 0, data: []],
#  dns_query: [domain: :undefined, type: :undefined, class: :undefined]]
# iex(3)> Keyword.get(recs, :dns_header)
# [id: 0, qr: 0, opcode: 0, aa: 0, tc: 0, rd: 0, ra: 0, pr: 0, rcode: 0]


# {:dns_rec,
#     {:dns_header, 19591, false, :query, false, false, true, false, false, 0},
#     [{:dns_query, 'incoming.telemetry.mozilla.org', :a, :in}],
#     [], [], []}



# {:dns_rec,
#     {:dns_header, 19591, true, :query, false, false, true, true, false, 0},
#     [{:dns_query, 'incoming.telemetry.mozilla.org', :a, :in}],
#     [
#      {:dns_rr, 'incoming.telemetry.mozilla.org', :cname, :in, 0, 36, 'telemetry-incoming.r53-2.services.mozilla.com', :undefined, [], false},
#      {:dns_rr, 'telemetry-incoming.r53-2.services.mozilla.com', :cname, :in, 0, 36, 'pipeline-tee-n-elb-1tsslcqosx8ko-1925318787.us-west-2.elb.amazonaws.com', :undefined, [], false},
#      {:dns_rr, 'pipeline-tee-n-elb-1tsslcqosx8ko-1925318787.us-west-2.elb.amazonaws.com', :a, :in, 0, 36, {52, 41, 79, 181}, :undefined, [], false},
#      {:dns_rr, 'pipeline-tee-n-elb-1tsslcqosx8ko-1925318787.us-west-2.elb.amazonaws.com', :a, :in, 0, 36, {52, 42, 151, 215}, :undefined, [], false},
#      {:dns_rr, 'pipeline-tee-n-elb-1tsslcqosx8ko-1925318787.us-west-2.elb.amazonaws.com', :a, :in, 0, 36, {52, 38, 176, 216}, :undefined, [], false},
#      {:dns_rr, 'pipeline-tee-n-elb-1tsslcqosx8ko-1925318787.us-west-2.elb.amazonaws.com', :a, :in, 0, 36, {54, 148, 213, 147}, :undefined, [], false},
#      {:dns_rr, 'pipeline-tee-n-elb-1tsslcqosx8ko-1925318787.us-west-2.elb.amazonaws.com', :a, :in, 0, 36, {54, 201, 239, 157}, :undefined, [], false},
#      {:dns_rr, 'pipeline-tee-n-elb-1tsslcqosx8ko-1925318787.us-west-2.elb.amazonaws.com', :a, :in, 0, 36, {54, 186, 208, 121}, :undefined, [], false},
#      {:dns_rr, 'pipeline-tee-n-elb-1tsslcqosx8ko-1925318787.us-west-2.elb.amazonaws.com', :a, :in, 0, 36, {54, 71, 133, 14}, :undefined, [], false},
#      {:dns_rr, 'pipeline-tee-n-elb-1tsslcqosx8ko-1925318787.us-west-2.elb.amazonaws.com', :a, :in, 0, 36, {54, 68, 110, 166}, :undefined, [], false}
#     ]
# , [], []}


  def record_to_keyword(tuple, rec_fields_list) do
    [rec_type | fields] = Tuple.to_list(tuple)

    case is_atom(rec_type) do
      true -> case Keyword.get(rec_fields_list, rec_type) do
                nil -> tuple
                type_list ->  Enum.zip(type_list, fields)
                    |>  Enum.map( fn {{field, _default},value} -> {field, value} end )
              end
      _ -> tuple
    end
  end

  @doc """
  Takes any arbitrary Elixir data structure and the results of Record.extract_all(1)
  and replaces any Erlang records found in the data with keyword maps.
  """
  def to_keyword(data, rec_fields_list) do
    keyword_potion = %{ Tuple => fn(tuple) -> record_to_keyword(tuple, rec_fields_list) end}
    transform(data, keyword_potion)
  end


end
