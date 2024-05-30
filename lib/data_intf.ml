module type QUEUE = sig
  type 'a t
  val create : unit -> 'a t
  val push : 'a t -> 'a  -> unit
  val pop_opt : 'a t -> 'a option
end
