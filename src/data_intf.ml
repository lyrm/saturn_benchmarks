module type QUEUE = sig
  type 'a t

  val create : unit -> 'a t
  val push_exn : 'a t -> 'a -> unit
  val pop_opt : 'a t -> 'a option
end

module type SPSC_queue = sig 
  type 'a t 

  val create : size_exponent:int -> 'a t 
  val try_push : 'a t -> 'a -> bool
  val push_exn : 'a t -> 'a -> unit
  val pop_exn : 'a t -> 'a
  val pop_opt : 'a t -> 'a option

  val size : 'a t -> int
end  