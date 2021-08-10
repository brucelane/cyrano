/*
 Copyright (c) 2013-2020, Bruce Lane - All rights reserved.
 This code is intended for use with the Cinder C++ library: http://libcinder.org

 Using Cinder-Warping from Paul Houx.

 Cinder-Warping is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Cinder-Warping is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Cinder-Warping.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"

 // Animation
#include "VDAnimation.h"
// Session Facade
#include "VDSessionFacade.h"
// Spout
#include "CiSpoutOut.h"
// Video
//#include "ciWMFVideoPlayer.h"
// Uniforms
#include "VDUniforms.h"
// Params
#include "VDParams.h"
// Mix
#include "VDMix.h"
// hhtp(s)
#include "cinder/http/http.hpp"

// UI
#define IMGUI_DISABLE_OBSOLETE_FUNCTIONS 1
#include "VDUI.h"
#define IM_ARRAYSIZE(_ARR)			((int)(sizeof(_ARR)/sizeof(*_ARR)))
using namespace ci;
using namespace ci::app;
using namespace videodromm;

class CyranoApp : public App {
public:
	CyranoApp();
	void cleanup() override;
	void update() override;
	void draw() override;
	void resize() override;
	void mouseMove(MouseEvent event) override;
	void mouseDown(MouseEvent event) override;
	void mouseDrag(MouseEvent event) override;
	void mouseUp(MouseEvent event) override;
	void keyDown(KeyEvent event) override;
	void keyUp(KeyEvent event) override;
	void fileDrop(FileDropEvent event) override;
private:
	// Settings
	VDSettingsRef					mVDSettings;
	// Animation
	VDAnimationRef					mVDAnimation;
	// Session
	VDSessionFacadeRef				mVDSessionFacade;
	// Mix
	VDMixRef						mVDMix;
	// Uniforms
	VDUniformsRef					mVDUniforms;
	// Params
	VDParamsRef						mVDParams;
	// UI
	VDUIRef							mVDUI;
	// video
	/*ciWMFVideoPlayer				mVideo;
	float							mVideoPos;
	float							mVideoDuration;
	bool							mIsVideoLoaded;*/

	bool							mFadeInDelay = true;
	void							toggleCursorVisibility(bool visible);
	SpoutOut 						mSpoutOut;

	void makeRequest(http::UrlRef url);
	std::shared_ptr<ci::http::Session>		session;
	std::shared_ptr<ci::http::SslSession>	sslSession;
	ci::gl::TextureRef texture;
	http::UrlRef							httpsUrl;
	bool useHttp = false;
};


CyranoApp::CyranoApp() : mSpoutOut("Cyrano", app::getWindowSize())
{

	// Settings
	mVDSettings = VDSettings::create("Cyrano");
	// Uniform
	mVDUniforms = VDUniforms::create();
	// Params
	mVDParams = VDParams::create();
	// Animation
	mVDAnimation = VDAnimation::create(mVDSettings, mVDUniforms);
	// Mix
	mVDMix = VDMix::create(mVDSettings, mVDAnimation, mVDUniforms);
	// Session
	mVDSessionFacade = VDSessionFacade::createVDSession(mVDSettings, mVDAnimation, mVDUniforms, mVDMix)
		->setUniformValue(mVDUniforms->IBPM, 160.0f)
		->setUniformValue(mVDUniforms->IMOUSEX, 0.27710f)
		->setUniformValue(mVDUniforms->IMOUSEY, 0.5648f)
		->setMode(7)
		->setupWSClient()
		->wsConnect()
		//->setupMidiReceiver()
		//->addOSCObserver(mVDSettings->mOSCDestinationHost, mVDSettings->mOSCDestinationPort)
		->getWindowsResolution()
		->addUIObserver(mVDSettings, mVDUniforms)
		->toggleUI()
		->toggleValue(mVDUniforms->IFLIPPOSTV)
		->toggleValue(mVDUniforms->IFLIPV);

	// sos only mVDSessionFacade->setUniformValue(mVDSettings->IEXPOSURE, 1.93f);
	mFadeInDelay = true;
	// UI

	mVDUI = VDUI::create(mVDSettings, mVDSessionFacade, mVDUniforms);
	//httpsUrl = std::make_shared<http::Url>("https://upload.wikimedia.org/wikipedia/commons/d/da/Internet2.jpg");
	httpsUrl = std::make_shared<http::Url>("https://localhost:44377/WeatherForecast");

	makeRequest(httpsUrl);
}

void CyranoApp::makeRequest(http::UrlRef url)
{
	auto request = std::make_shared<http::Request>(http::RequestMethod::GET, url);
	request->appendHeader(http::Connection(http::Connection::Type::CLOSE));
	request->appendHeader(http::Accept());

	auto onComplete = [&](asio::error_code ec, http::ResponseRef response) {
		CI_LOG_W(ci::DataSourceBuffer::create(response->getContent()));
		//texture = ci::gl::Texture::create(loadImage(ci::DataSourceBuffer::create(response->getContent()),
			//ImageSource::Options(), ".jpg"));
	};
	auto onError = [](asio::error_code ec, const http::UrlRef &url, http::ResponseRef response) {
		CI_LOG_E(ec.message() << " val: " << ec.value() << " Url: " << url->to_string());
		if (response) {
			app::console() << "Headers: " << std::endl;
			app::console() << response->getHeaders() << endl;
		}
	};

	if (url->port() == 80) {
		session = std::make_shared<http::Session>(request, onComplete, onError);
		session->start();
	}
	else if (url->port() == 443) {
		sslSession = std::make_shared<http::SslSession>(request, onComplete, onError);
		sslSession->start();
	}
}

void CyranoApp::toggleCursorVisibility(bool visible)
{
	if (visible)
	{
		showCursor();
	}
	else
	{
		hideCursor();
	}
}

void CyranoApp::fileDrop(FileDropEvent event)
{
	mVDSessionFacade->fileDrop(event);
}

void CyranoApp::mouseMove(MouseEvent event)
{
	if (!mVDSessionFacade->handleMouseMove(event)) {

	}
}

void CyranoApp::mouseDown(MouseEvent event)
{

	if (!mVDSessionFacade->handleMouseDown(event)) {

	}
}

void CyranoApp::mouseDrag(MouseEvent event)
{

	if (!mVDSessionFacade->handleMouseDrag(event)) {

	}
}

void CyranoApp::mouseUp(MouseEvent event)
{

	if (!mVDSessionFacade->handleMouseUp(event)) {

	}
}

void CyranoApp::keyDown(KeyEvent event)
{

	// warp editor did not handle the key, so handle it here
	if (!mVDSessionFacade->handleKeyDown(event)) {
		switch (event.getCode()) {
		case KeyEvent::KEY_F12:
			// quit the application
			quit();
			break;
		case KeyEvent::KEY_f:
			// toggle full screen
			setFullScreen(!isFullScreen());
			break;

		case KeyEvent::KEY_l:
			mVDSessionFacade->createWarp();
			break;
		}
	}
}

void CyranoApp::keyUp(KeyEvent event)
{

	// let your application perform its keyUp handling here
	if (!mVDSessionFacade->handleKeyUp(event)) {
		/*switch (event.getCode()) {
		default:
			CI_LOG_V("main keyup: " + toString(event.getCode()));
			break;
		}*/
	}
}
void CyranoApp::cleanup()
{
	CI_LOG_V("cleanup and save");
	ui::Shutdown();
	mVDSessionFacade->saveWarps();
	mVDSettings->save();
	CI_LOG_V("quit");
}

void CyranoApp::update()
{
	/*switch (mVDSessionFacade->getCmd()) {
	case 0:
		//createControlWindow();
		break;
	case 1:
		//deleteControlWindows();
		break;
	}*/
	mVDSessionFacade->setUniformValue(mVDUniforms->IFPS, getAverageFps());
	mVDSessionFacade->update();
	/*mVideo.update();
	mVideoPos = mVideo.getPosition();
	if (mVideo.isStopped() || mVideo.isPaused()) {
		mVideo.setPosition(0.0);
		mVideo.play();
	}*/
}


void CyranoApp::resize()
{
	mVDUI->resize();
}
void CyranoApp::draw()
{
	// clear the window and set the drawing color to white
	gl::clear();
	gl::color(Color::white());
	if (mFadeInDelay) {
		mVDSettings->iAlpha = 0.0f;
		if (getElapsedFrames() > 10.0) {// mVDSessionFacade->getFadeInDelay()) {
			mFadeInDelay = false;
			timeline().apply(&mVDSettings->iAlpha, 0.0f, 1.0f, 1.5f, EaseInCubic());
		}
	}
	else {
		gl::setMatricesWindow(mVDParams->getFboWidth(), mVDParams->getFboHeight(), false);
		//gl::setMatricesWindow(mVDSessionFacade->getIntUniformValueByIndex(mVDSettings->IOUTW), mVDSessionFacade->getIntUniformValueByIndex(mVDSettings->IOUTH), true);
		// textures needs updating
		for (int t = 0; t < mVDSessionFacade->getInputTexturesCount(); t++) {
			mVDSessionFacade->getInputTexture(t);
		}
		unsigned int m = mVDSessionFacade->getMode();
		if (m < mVDSessionFacade->getFboShaderListSize()) {
			gl::draw(mVDSessionFacade->getFboShaderTexture(m));
			mSpoutOut.sendTexture(mVDSessionFacade->getFboShaderTexture(m));
		}
		else {
			if (m == 8) {
				gl::draw(mVDSessionFacade->buildRenderedMixetteTexture(0));
				mSpoutOut.sendTexture(mVDSessionFacade->buildRenderedMixetteTexture(0));
			}
			else if (m == 7) {
				gl::draw(mVDSessionFacade->buildPostFboTexture());
				mSpoutOut.sendTexture(mVDSessionFacade->buildPostFboTexture());
			}
			else {
				gl::draw(mVDSessionFacade->buildRenderedMixetteTexture(0), Area(50, 50, mVDParams->getFboWidth() / 2, mVDParams->getFboHeight() / 2));
				gl::draw(mVDSessionFacade->buildPostFboTexture(), Area(mVDParams->getFboWidth() / 2, mVDParams->getFboHeight() / 2, mVDParams->getFboWidth(), mVDParams->getFboHeight()));
			}
			//gl::draw(mVDSession->getRenderedMixetteTexture(0), Area(0, 0, mVDSettings->mFboWidth, mVDSettings->mFboHeight));
			// ok gl::draw(mVDSession->getWarpFboTexture(), Area(0, 0, mVDSettings->mFboWidth, mVDSettings->mFboHeight));//getWindowBounds()
			//mSpoutOut.sendTexture(mVDSession->getRenderedMixetteTexture(0));
		}
		/*vec2 videoSize = vec2(mVideo.getWidth(), mVideo.getHeight());
		mGlslVideoTexture->uniform("uVideoSize", videoSize);
		videoSize *= 0.25f;
		videoSize *= 0.5f;
		ciWMFVideoPlayer::ScopedVideoTextureBind scopedVideoTex(mVideo, 0);
		gl::scale(vec3(videoSize, 1.0f));*/

		//gl::draw(mPostFbo->getColorTexture());
		//gl::draw(mVDSessionFacade->getFboRenderedTexture(0));
		if (texture)
			gl::draw(texture, texture->getBounds(), Rectf(vec2(0.0f), vec2(130.0f, 80.0f)));

	}

	// imgui
	if (mVDSessionFacade->showUI()) {
		mVDUI->Run("UI", (int)getAverageFps());
		if (mVDUI->isReady()) {
		}
	}
	getWindow()->setTitle(toString((int)getAverageFps()) + " fps");
}
void prepareSettings(App::Settings *settings)
{
	settings->setWindowSize(1280, 720);
}
CINDER_APP(CyranoApp, RendererGl(RendererGl::Options().msaa(8)), prepareSettings)

