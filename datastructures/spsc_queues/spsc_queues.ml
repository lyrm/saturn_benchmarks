module type SPSC_QUEUE = Spcs_queue_intf.SPSC_queue

module Spsc_queue_original : SPSC_QUEUE = Original_spsc_queue
(** Original spsc without optimizations *)

module Spsc_queue_with_padding : SPSC_QUEUE = Padded_spsc_queue
(** Original spsc with padding using Multicore_magic.copy_as_padded *)

module Saturn_spsc_queue_no_padding : SPSC_QUEUE = Saturn_spsc_without_padding
(** Saturn Spsc queue without padding*)

module Saturn_spsc_queue : SPSC_QUEUE =
  Saturn_lockfree.Single_prod_single_cons_queue
(** Spsc queue from Saturn *)

module Saturn_spsc_queue_with_full_padding : SPSC_QUEUE =
  Saturn_spsc_with_full_padding
(** Saturn Spsc queue with full padding*)

module Saturn_spsc_queue_with_padding_relaxed_read : SPSC_QUEUE =
  Saturn_spsc_with_padding_relaxed_read
(** Saturn Spsc queue with padding and relaxed read*)

module Saturn_spsc_with_padding_relaxed_option : SPSC_QUEUE =
  Saturn_spsc_with_padding_relaxed_option
(** Saturn Spsc queue with padding, relaxed read and without indirection in array*)

module Saturn_spsc_queue_unsafe : SPSC_QUEUE =
  Saturn_lockfree.Single_prod_single_cons_queue_unsafe
