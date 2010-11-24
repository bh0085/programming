#ifdef __cplusplus
#import "Box2D.h"
#import <vector>
#import "bgHeaders.h"
using namespace std;
class GLIController;
#else
#include "GLIController.h"
#endif


#define MAX_GENES 200
#define N_BYTES 50
typedef struct geneStream {
	int maxGenes;
	int nBytes;
	int byteCushion;
	int nGenes;
	unsigned char stream[N_BYTES*MAX_GENES];
	
};

#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
	class AsteroidsGame{
	private:
		b2World * world;
		vector <bgActor *> actors;
		bgSkeleton * skeleton;
		GLIController * cont;
	public:
		AsteroidsGame();
		~AsteroidsGame();
		void timeStep();
		b2World * getWorld();
		bgSkeleton * makeSkeleton();
	};
	
	void makeByteStream(geneStream * gs);
	void readByteStream(geneStream * gs, AsteroidsGame * game);
	
#else
	typedef struct AsteroidsGame AsteroidsGame;
#endif
	void asteroidsCommandDown(AsteroidsGame * game,float constant);
	void asteroidsCommandUp(AsteroidsGame * game,float constant);
	void asteroidsCommandLeft(AsteroidsGame * game,float constant);
	void asteroidsCommandRight(AsteroidsGame * game,float constant);
	AsteroidsGame * makeGame(GLIController * c);
	void destroyGame(AsteroidsGame * game);
	void gameTimeStep(AsteroidsGame * game);
#ifdef __cplusplus
}
#endif
