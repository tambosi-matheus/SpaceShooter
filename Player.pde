Player player;

public class Player extends Solid
{ 
  private PVector acel, firePoint;
  private float maxSpeed = 20, maxAcel= 10, angle, 
    fireRate = 8, fireCooldown, bulletSpeed = 50, 
    fireRandomness = 0.05f, fireOffset = 20;
  public boolean isDead = false;

  public Player()
  {
    pos = new PVector(size.x/2, size.y/2);
    vel = new PVector();
    collRadius = 20;

    acel = new PVector();
    firePoint = new PVector();
  }

  public void Update()
  {
    if (isDead)
    {
      if (!audio_player_death.isPlaying())
        ChangeGameState(GameStates.END);
      return;
    }
    Movimentation();
    Shoot();
  }

  private void Movimentation()
  {
    //calc rotation
    if (mouseRight)
      angle = PVector.sub(mouse, pos).heading() + HALF_PI; 
    else if (vel.mag() > 0.1f)
      angle = vel.heading() + HALF_PI;    


    //set acceleration and velocity
    vel = vel.mult(0.9f);
    if (vel.mag() < 0.1f) vel = new PVector(0, 0);
    acel = new PVector((int(keyA) - int(keyD)), (int(keyW) - int(keyS)));
    acel.normalize().mult(maxAcel);
    vel.add(acel);
    if (vel.mag() > maxSpeed)       
      vel.normalize().mult(maxSpeed);
    PVector finalVel = vel.copy();
    finalVel.mult(deltaTime);
    PVector boundaries = PVector.add(finalVel, pos);
    if (boundaries.x + 200 < size.x && boundaries.x > 200)
      pos.x += finalVel.x;
    if(boundaries.y + 200< size.y && boundaries.y > 200) 
      pos.y += finalVel.y;
  }

  private void Shoot()
  {
    fireCooldown += deltaTime;
    if (mouseRight &&  fireCooldown > 10 / fireRate)
    {
      float fireAngle = angle + random(-fireRandomness, fireRandomness);
      firePoint = new PVector(0, -fireOffset).rotate(angle);
      addSolids.add(new PlayerBullet(PVector.add(pos, firePoint), bulletSpeed, fireAngle));
      audio_player_shooting.stop();
      audio_player_shooting.play();
      fireCooldown = 0;
    }
  }

  public void Collision(ArrayList<Solid> grid)
  {   
    for (Solid s : grid)
    {
      if (s == this)     
        continue;

      if (Util.CheckCollision(pos, collRadius, s.pos, s.collRadius))
      {        
        String solidClass = s.getClass().toGenericString();
        if (!isDead &&(
          solidClass.equals("public class SpaceShooter$SmallEnemy")|| 
          solidClass.equals("public class SpaceShooter$MediumEnemy")||
          solidClass.equals("public class SpaceShooter$MediumEnemyBullet")||
          solidClass.equals("public class SpaceShooter$BigEnemy")))
        {
          OnPlayerHit();
        }
      }
    }
  }

  public void OnPlayerHit()
  {
    if (isDead) return;
    activeAnimations.add(new AnimationPlayerExplosion(pos));
    audio_main_background.stop();
    audio_player_death.stop();
    audio_player_death.play();
    isDead = true;
  }

  public void Show()
  {
    if (isDead) return;
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    if (acel.x < 0.5)
      image(image_player_right, 0, 0);
    else if (acel.x > 0.5)
      image(image_player_left, 0, 0);
    else
      image(image_player_middle, 0, 0);

    popMatrix();
  }
}

//--------------------------------------------------------------------------------//

public class PlayerBullet extends Solid
{
  private float angle;

  public PlayerBullet(PVector pos, float speed, float angle)
  {
    this.pos = pos;    
    super.collRadius = 15;
    vel = new PVector(0, -1);
    vel.rotate(angle).mult(speed);

    this.angle = angle;
  }

  public void Update()
  {
    PVector add = vel.copy();
    add.mult(deltaTime);
    pos.add(add);
  }

  public void Collision(ArrayList<Solid> grid)
  {   
    for (Solid s : grid)
    {
      if (s == this)     
        continue;

      if (Util.CheckCollision(pos, collRadius, s.pos, s.collRadius))
      {   
        if (s.getClass().toGenericString().equals("public class SpaceShooter$SmallEnemy"))
        {
          score += 50;
          removeSolids.add(this);
          removeSolids.add(s);          
          activeAnimations.add(new AnimationEnemyExplosion(pos));       
          audio_enemy_small_death.stop();
          audio_enemy_small_death.play();
          break;
        } else if (s.getClass().toGenericString().equals("public class SpaceShooter$MediumEnemy"))
        {
          score += 250;
          removeSolids.add(this);
          removeSolids.add(s);
          activeAnimations.add(new AnimationEnemyExplosion(pos));
          audio_enemy_medium_death.stop();
          audio_enemy_medium_death.play();
          break;
        } else if (s.getClass().toGenericString().equals("public class SpaceShooter$BigEnemy"))
        {
          score += 1000;
          removeSolids.add(this);
          removeSolids.add(s);
          activeAnimations.add(new AnimationEnemyExplosion(pos));
          audio_enemy_big_death.stop();
          audio_enemy_big_death.play();
          break;
        }
      }
    }
  }

  public void Show()
  {
    pushMatrix();

    translate(pos.x, pos.y);
    rotate(angle);
    fill(255, 0, 0);
    image(image_player_bullet, 0, 0);

    popMatrix();
  }
}
