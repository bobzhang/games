///|
test "process_sound_queue handles empty queue" {
  let queue : Array[@types.SoundEvent] = []
  @audio.process_sound_queue(queue)
  inspect(queue.length(), content="0")
}

///|
test "process_sound_queue handles events" {
  let queue : Array[@types.SoundEvent] = [PlayerShoot, EnemyHit, Explosion]
  @audio.process_sound_queue(queue)
  inspect(queue.length(), content="3")
}
