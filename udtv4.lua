-- REFERENCE
-- http://downloads.sourceforge.net/project/udt/udt/4.11/udt.sdk.4.11.tar.gz
 
udt_proto = Proto("UDTv4","UDT packet")
udt_seq_F = ProtoField.uint32("udt.seq", "Sequence number")
udt_mess_F = ProtoField.uint32("udt.mess", "Message number",base.HEX)
udt_timestamp_F = ProtoField.uint32("udt.timestamp", "Timestamp")
udt_socketid_F = ProtoField.uint32("udt.socketid", "Socket ID",base.HEX)
local VALS_BOOL = {[0] = "False", [1] = "True"}
--udt_nextmess_F = ProtoField.uint32("udt.nextmess_bit","Next Message", base.HEX, VALS_BOOL, 0x20000000)
udt_nextmess_F = ProtoField.uint32("udt.nextmess_bit","Message", base.HEX, VALS_BOOL, 0x20000000)
--udt_lastmess_F = ProtoField.uint32("udt.lastmess_bit","Last Message", base.HEX, VALS_BOOL, 0x40000000)
udt_proto.fields = {udt_seq_F, udt_mess_F, udt_timestamp_F, udt_socketid_F, udt_nextmess_F }
 
function udt_proto.dissector(buffer,pinfo,tree)
  
 local udt_seq_range = buffer(0,4)
 local udt_mess_range = buffer(4,4)
 local udt_timestamp_range = buffer(8,4)
 local udt_socketid_range = buffer(12,4)

 local udt_seq = udt_seq_range:uint()
 local udt_mess = udt_mess_range:uint()
 local udt_timestamp = udt_timestamp_range:uint()
 local udt_socketid = udt_socketid_range:uint()

 local subtree = tree:add(udt_proto, buffer(0,16), "UDP-based Data Transfer")
 subtree:add(udt_seq_F, udt_seq_range, udt_seq)
 local subflagatree = subtree:add(udt_mess_F, udt_mess_range, udt_mess)
 subflagatree:add(udt_nextmess_F, udt_mess_range, udt_mess)
 --subflagatree:add(udt_lastmess_F, udt_mess_range, udt_mess)
 --subtree:add(udt_mess_F, udt_mess_range, udt_mess)
 subtree:add(udt_timestamp_F, udt_timestamp_range, udt_timestamp)
 subtree:add(udt_socketid_F, udt_socketid_range, udt_socketid)

 Dissector.get("data"):call(buffer(16,buffer:len()-16):tvb(), pinfo, tree)
end
DissectorTable.get("udp.port"):add(9000, udt_proto)
