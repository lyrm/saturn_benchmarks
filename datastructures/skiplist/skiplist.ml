module type SKIPLIST = Skiplist_intf.SKIPLIST

module Saturn_skiplist : SKIPLIST = Skiplist_curr
module Skiplist_with_atoarr : SKIPLIST = Skiplist_with_atoarr
