#include "PEPPER.hpp"
#include "fbridge.cc"
#include <cstdlib>
#include <typeinfo>

struct fbridgeRunner{
    std::vector<FORTRANFPTYPE> rndHel;
    std::vector<FORTRANFPTYPE> rndCol;
    std::vector<int> selHel;
    std::vector<int> selCol;
    CppObjectInFortran *fBridge;
    const unsigned int chanId = 0;
    const int nMom = 4;
    int nEvt;
    int nPar;
    fbridgeRunner(){}
    fbridgeRunner( PEP::lheNode& lheFile ){
        if( !lheFile.isParsed() ){ lheFile.deepParse(); }
        nEvt = lheFile.events.size();
        rndHel = std::vector<FORTRANFPTYPE>( nEvt, 0. );
        rndCol = std::vector<FORTRANFPTYPE>( nEvt, 0. );
        selHel = std::vector<int>( nEvt, 0 );
        selCol = std::vector<int>( nEvt, 0 );
        nPar = lheFile.events[0]->getPrts().size();
    }
    fbridgeRunner( std::shared_ptr<PEP::lheNode> lheFile ){
        if(!lheFile->isParsed() ){ lheFile->deepParse(); }
        nEvt = lheFile->events.size();
        rndHel = std::vector<FORTRANFPTYPE>( nEvt, 0. );
        rndCol = std::vector<FORTRANFPTYPE>( nEvt, 0. );
        selHel = std::vector<int>( nEvt, 0 );
        selCol = std::vector<int>( nEvt, 0 );
        nPar = lheFile->events[0]->getPrts().size();
    }
#if defined MGONGPU_FPTYPE_FLOAT
    std::shared_ptr<std::vector<FORTRANFPTYPE>> scatAmp( std::shared_ptr<std::vector<float>> momenta, std::shared_ptr<std::vector<float>> alphaS ){
        auto evalScatAmps = std::make_shared<std::vector<FORTRANFPTYPE>>( nEvt );
        fbridgecreate_( &fBridge, &nEvt, &nPar, &nMom );
        fbridgesequence_( &fBridge, &momenta->at(0), &alphaS->at(0), &rndHel[0], &rndCol[0], &chanId, &evalScatAmps->at(0), &selHel[0], &selCol[0] );
        fbridgedelete_( &fBridge );
        return evalScatAmps;
    }
    std::shared_ptr<std::vector<FORTRANFPTYPE>> scatAmp( std::vector<float>& momenta, std::vector<float>& alphaS ){
        auto evalScatAmps = std::make_shared<std::vector<FORTRANFPTYPE>>( nEvt );
        fbridgecreate_( &fBridge, &nEvt, &nPar, &nMom );
        fbridgesequence_( &fBridge, &momenta[0], &alphaS[0], &rndHel[0], &rndCol[0], &chanId, &evalScatAmps->at(0), &selHel[0], &selCol[0] );
        fbridgedelete_( &fBridge );
        return evalScatAmps;
    }
#endif
    std::shared_ptr<std::vector<FORTRANFPTYPE>> scatAmp( std::shared_ptr<std::vector<double>> momenta, std::shared_ptr<std::vector<double>> alphaS ){
#if defined MGONGPU_FPTYPE_FLOAT
        auto nuMom = std::make_shared<std::vector<float>>( nEvt );
        auto nuAlphaS = std::make_shared<std::vector<float>>( nEvt );
        std::transform( momenta->begin(), momenta->end(), nuMom->begin(), [](double mom){ return static_cast<float>(mom); });
        std::transform( alphaS->begin(), alphaS->end(), nuAlphaS->begin(), [](double gs){ return static_cast<float>(gs); });
        return scatAmp( nuMom, nuAlphaS );
#elif defined MGONGPU_FPTYPE_DOUBLE
        auto evalScatAmps = std::make_shared<std::vector<FORTRANFPTYPE>>( nEvt );
        fbridgecreate_( &fBridge, &nEvt, &nPar, &nMom );
        fbridgesequence_( &fBridge, &momenta->at(0), &alphaS->at(0), &rndHel[0], &rndCol[0], &chanId, &evalScatAmps->at(0), &selHel[0], &selCol[0] );
        fbridgedelete_( &fBridge );
        return evalScatAmps;
#endif
    }
    std::shared_ptr<std::vector<FORTRANFPTYPE>> scatAmp( std::vector<double>& momenta, std::vector<double>& alphaS ){
#if defined MGONGPU_FPTYPE_FLOAT
        auto nuMom = std::vector<float>( nEvt );
        auto nuAlphaS = std::vector<float>( nEvt );
        std::transform( momenta.begin(), momenta.end(), nuMom.begin(), [](double mom){ return static_cast<float>(mom); });
        std::transform( alphaS.begin(), alphaS.end(), nuAlphaS.begin(), [](double gs){ return static_cast<float>(gs); });
        return scatAmp( nuMom, nuAlphaS );
#elif defined MGONGPU_FPTYPE_DOUBLE
        auto evalScatAmps = std::make_shared<std::vector<FORTRANFPTYPE>>( nEvt );
        fbridgecreate_( &fBridge, &nEvt, &nPar, &nMom );
        fbridgesequence_( &fBridge, &momenta[0], &alphaS[0], &rndHel[0], &rndCol[0], &chanId, &evalScatAmps[0], &selHel[0], &selCol[0] );
        fbridgedelete_( &fBridge );
        return evalScatAmps;
#endif
    }
};

std::shared_ptr<std::vector<double>> meEval( std::vector<double>& x, std::vector<double>& y){
    int random = rand() % 10;
    if( random == 0 ){ random = 11; }
    auto thisIsIt = std::make_shared<std::vector<double>>( y.size(), random );
    return thisIsIt;
}

int usage( char* argv0, int ret = 1 )
{
    std::cout << "Usage: " << argv0
        << " [--lhefile=\"/YOUR/PATH/HERE\"|-lhe=\"/YOUR/PATH/HERE\"] [--rwgtcard=/YOUR/PATH/HERE|-rwgt=\"/YOUR/PATH/HERE\"]\n"
        << "[--output=/YOUR/PATH/HERE\"|-out=\"/YOUR/PATH/HERE\"]\n";
    std::cout << "\n";
    std::cout << "The LHE file path should be with respect to the directory you are running\n";
    std::cout << "this program from, and similarly the rwgt_card should be as well.\n";
#if defined MGONGPU_FPTYPE_DOUBLE
    std::cout << "The program is currently compiled with double precision.\n";
#elif defined MGONGPU_FPTYPE_FLOAT
    std::cout << "The program is currently compiled with float precision.\n";
#else
    std::cout << "The program is currently compiled with an unrecognised precision -- FPTYPE is defined neither as float nor double for GPU evaluations.\n";
#endif
    std::cout << "Numerical precision can only be redefined at compile time.\nIf you wish to change the precision, please recompile with the option \"FPTYPE=f\"/\"FPTYPE=d\".";
    return ret;
}


int main( int argc, char** argv ){
    std::string lheFilePath;
    std::string rwgtCardPath;
    std::string outputPath;
    std::string slhaPath;

    // READ COMMAND LINE ARGUMENTS
    for( int argn = 1; argn < argc; ++argn )
    {
        std::string currArg = argv[argn];
        if( currArg.substr(0,9) == "--lhefile" || currArg.substr(0,4) == "-lhe" )
        {
            lheFilePath = currArg.substr( currArg.find( "=" ) + 1 ); 
        }
        else if( currArg.substr(0,10) == "--rwgtcard" || currArg.substr(0,5) == "-rwgt" )
        {
            rwgtCardPath = currArg.substr( currArg.find( "=" ) + 1 );
        } else if( currArg.substr(0,8) == "--output" || currArg.substr(0,4) == "-out" ){
            outputPath = currArg.substr( currArg.find( "=" ) + 1 );
        } else
        {
            return usage( argv[0] );
        }
    }

    if( lheFilePath.empty() || rwgtCardPath.empty() ){
        return usage( argv[0] );
    }

    std::string currPath = argv[0];

    size_t slashPos = currPath.find_last_of( "/" ); 
    bool onWindows = false;
    if( slashPos == std::string::npos ){ slashPos = currPath.find_last_of( "\\" ); onWindows = true; }
    if( slashPos == std::string::npos )
        throw std::runtime_error( "Failed to determine current working directory -- need to know where program is run from to identify where to pull and push param_card.dat." );

    if( onWindows ){
        if( currPath.substr( currPath.find_last_of("\\", slashPos - 1) + 1, 2 ) == "P1" ){
            slhaPath = "..\\..\\Cards\\param_card.dat";
        } else{
            slhaPath = "\\Cards\\param_card.dat";
        }
    } else {
        if( currPath.substr( currPath.find_last_of("/", slashPos - 1) + 1, 2 ) == "P1" ){
            slhaPath = "../../Cards/param_card.dat";
        } else {
            slhaPath = "/Cards/param_card.dat";
        }
    }
    

    PEP::PER::rwgtFiles fileCol( lheFilePath, slhaPath, rwgtCardPath );
    fileCol.initCards();

    auto bridgeCont = fbridgeRunner( fileCol.getLhe() );

    std::function<std::shared_ptr<std::vector<FORTRANFPTYPE>>(std::vector<double>&, std::vector<double>&)> scatteringAmplitude =
    [&bridgeCont](std::vector<double>& momenta, std::vector<double>& alphaS) {
        return bridgeCont.scatAmp(momenta, alphaS);
    };
    PEP::PER::rwgtRunner nuRun( fileCol, scatteringAmplitude );


    nuRun.runRwgt( outputPath ); 
 
    return 0;

}