
Namespace mojo3d

#Import "native/collisiondetect.cpp"
#Import "native/collisiondetect.h"

Extern Private

Function initCollisions( world:btDynamicsWorld )
Function resetCollisions()
Function getNumCollisions:Int()
Function getCollisions:Void Ptr Ptr()

Public

Class World
	
	Method New( scene:Scene )
		
		_scene=scene
		
		Local broadphase:=New btDbvtBroadphase()
		
		Local config:=New btDefaultCollisionConfiguration()

		Local dispatcher:=New btCollisionDispatcher( config )
		
		Local solver:=New btSequentialImpulseConstraintSolver()
		
		_btworld=New btDiscreteDynamicsWorld( dispatcher,broadphase,solver,config )
		
		initCollisions( _btworld )

		Gravity=New Vec3f( 0,-9.81,0 )
	End
	
	Property Scene:Scene()
	
		Return _scene
	End

	Property Gravity:Vec3f()
	
		Return _btworld.getGravity()
		
	Setter( gravity:Vec3f )
	
		_btworld.setGravity( gravity )
	End
	
	Method RayCast:RayCastResult( rayFrom:Vec3f,rayTo:Vec3f,collisionMask:Int )
		
		Local btresult:=New btCollisionWorld.ClosestRayResultCallback( rayFrom,rayTo )
		
		btresult.m_collisionFilterGroup=collisionMask
		btresult.m_collisionFilterMask=collisionMask
		
		_btworld.rayTest( rayFrom,rayTo,Cast<btCollisionWorld.RayResultCallback Ptr>( Varptr btresult ) )
		
		If Not btresult.hasHit() Return Null
		
		Return New RayCastResult( Varptr btresult )
	End
	
	Method ConvexSweep:RayCastResult( collider:ConvexCollider,castFrom:AffineMat4f,castTo:AffineMat4f )
		
		Local btresult:=New btCollisionWorld.ClosestConvexResultCallback( castFrom.t,castTo.t )
		
		_btworld.convexSweepTest( Cast<btConvexShape>( collider.btShape ),castFrom,castTo,Cast<btCollisionWorld.ConvexResultCallback Ptr>( Varptr btresult ),0 )
		
		If Not btresult.hasHit() Return Null
		
		Return New RayCastResult( Varptr btresult )
	End
	
	Method ConvexSweep:RayCastResult( collider:ConvexCollider,castFrom:Vec3f,castTo:Vec3f )
		
		Return ConvexSweep( collider,AffineMat4f.Translation( castFrom ),AffineMat4f.Translation( castTo ) )
	End

	Method Update( elapsed:Float )
		
		resetCollisions()
		
		_btworld.stepSimulation( 1.0/60.0 )
		
		Local n:=getNumCollisions()
		
		Local p:=getCollisions()
		
		For Local i:=0 Until n
			
			Local body0:=Cast<RigidBody>( p[i*2] )
			Local body1:=Cast<RigidBody>( p[i*2+1] )

			Local entity0:=body0.Entity
			Local entity1:=body1.Entity
			
			entity0.Collide( body1 )
			entity1.Collide( body0 )
			
'			body0.Entity.Collide( body1 )
'			body1.Entity.Collide( body0 )
			
'			Print "Collision:"+entity0.Name+"->"+entity1.Name
			
		Next
		
		resetCollisions()
		
	End
	
	Property btWorld:btDynamicsWorld()
		
		Return _btworld
	End
	
	Internal
	
	Method Add( body:RigidBody )
		
		Print "World.Add( RigidBody )"
		
		_bodies.Add( body )
		
		Local btbody:=body.btBody
		
		btbody.setUserPointer( Cast<Void Ptr>( body ) )
		
		_btworld.addRigidBody( btbody,body.CollisionGroup,body.CollisionMask )
	End
	
	Method Remove( body:RigidBody )
		
		Print "World.Remove( RigidBody )"
		
		Local btbody:=body.btBody
		
		_btworld.removeRigidBody( btbody )
		
		body.btBody.setUserPointer( Null )

		_bodies.Remove( body )
	End
	
	Private
	
	Field _scene:Scene
	
	Field _btworld:btDynamicsWorld
	
	Field _newBodies:=New Stack<RigidBody>
	
	Field _bodies:=New Stack<RigidBody>

End
