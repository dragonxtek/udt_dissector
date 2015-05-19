  1 -- REFERENCE
  2 -- http://downloads.sourceforge.net/project/udt/udt/4.11/udt.sdk.4.11.tar.gz
  3 
  4 udt_proto = Proto("UDT","UDT packet")
  5 udt_seq_F = ProtoField.uint32("udt.seq", "Sequence number")
  6 udt_mess_F = ProtoField.uint32("udt.mess", "Message number",base.HEX)
  7 udt_timestamp_F = ProtoField.uint32("udt.timestamp", "Timestamp")
  8 udt_socketid_F = ProtoField.uint32("udt.socketid", "Socket ID",base.HEX)
  9 local VALS_BOOL = {[0] = "False", [1] = "True"}
 10 --udt_nextmess_F = ProtoField.uint32("udt.nextmess_bit","Next Message", base.HEX, VALS_BOOL, 0x20000000)
 11 udt_nextmess_F = ProtoField.uint32("udt.nextmess_bit","Message", base.HEX, VALS_BOOL, 0x20000000)
 12 --udt_lastmess_F = ProtoField.uint32("udt.lastmess_bit","Last Message", base.HEX, VALS_BOOL, 0x40000000)
 13 udt_proto.fields = {udt_seq_F, udt_mess_F, udt_timestamp_F, udt_socketid_F, udt_nextmess_F }
 14 
 15 function udt_proto.dissector(buffer,pinfo,tree)
 16  
 17  local udt_seq_range = buffer(0,4)
 18  local udt_mess_range = buffer(4,4)
 19  local udt_timestamp_range = buffer(8,4)
 20  local udt_socketid_range = buffer(12,4)
 21  
 22  local udt_seq = udt_seq_range:uint()
 23  local udt_mess = udt_mess_range:uint()
 24  local udt_timestamp = udt_timestamp_range:uint()
 25  local udt_socketid = udt_socketid_range:uint()
 26  
 27  local subtree = tree:add(udt_proto, buffer(0,16), "UDP-based Data Transfer")
 28  subtree:add(udt_seq_F, udt_seq_range, udt_seq)
 29  local subflagatree = subtree:add(udt_mess_F, udt_mess_range, udt_mess)
 30  subflagatree:add(udt_nextmess_F, udt_mess_range, udt_mess)
 31  --subflagatree:add(udt_lastmess_F, udt_mess_range, udt_mess)
 32  --subtree:add(udt_mess_F, udt_mess_range, udt_mess)
 33  subtree:add(udt_timestamp_F, udt_timestamp_range, udt_timestamp)
 34  subtree:add(udt_socketid_F, udt_socketid_range, udt_socketid)
 35 
 36 Dissector.get("data"):call(buffer(16,buffer:len()-16):tvb(), pinfo, tree)
 37 end
 38 DissectorTable.get("udp.port"):add(9000, udt_proto)
