import UIKit
import AVFoundation
import AVKit

class SplashAnimationViewController: UIViewController {

    private var player: AVPlayer?
    private var playerController = AVPlayerViewController()

    private var playerItemContext = 0

    private let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlayerController()
        setupPlayer()
    }

    private func setupPlayerController() {
        playerController = AVPlayerViewController()
        playerController.videoGravity = .resizeAspectFill
        playerController.showsPlaybackControls = false
        playerController.view.backgroundColor = .clear
        playerController.view.translatesAutoresizingMaskIntoConstraints = false
        playerController.view.isUserInteractionEnabled = false

        addChild(playerController)
        view.addSubview(playerController.view)
        playerController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            playerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerController.view.topAnchor.constraint(equalTo: view.topAnchor),
            playerController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if #available(iOS 10.0, *) {
            playerController.allowsPictureInPicturePlayback = false
            playerController.updatesNowPlayingInfoCenter = false
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerFailedToPlay),
                                               name: .AVPlayerItemFailedToPlayToEndTime,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appCameToForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    private func setupPlayer() {
        guard let path = Bundle.main.path(forResource: "start_animation", ofType: "mp4") else {
            dismiss(animated: false, completion: nil)
            return
        }

        let asset = AVAsset(url: URL(fileURLWithPath: path))
        let playerItem = AVPlayerItem(asset: asset,
                                      automaticallyLoadedAssetKeys: requiredAssetKeys)

        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.status),
                               options: [.old, .new],
                               context: &playerItemContext)

        player = AVPlayer(playerItem: playerItem)
        playerController.player = player
        player?.seek(to: .zero)
        player?.play()
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {

        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status),
           let statusNumber = change?[.newKey] as? NSNumber,
           let status = AVPlayerItem.Status(rawValue: statusNumber.intValue) {
            switch status {
            case .readyToPlay:
                print("Ready to play")
            case .failed:
                print("Playback failed: \(String(describing: player?.currentItem?.error))")
                dismiss(animated: false, completion: nil)
            case .unknown:
                print("Status unknown")
            @unknown default:
                break
            }
        }
    }

    @objc private func playerDidFinishPlaying() {
        player?.pause()
        player = nil
        dismiss(animated: false, completion: nil)
    }

    @objc private func playerFailedToPlay() {
        dismiss(animated: false, completion: nil)
    }

    @objc private func appCameToForeground() {
        print("App entered foreground")
        dismiss(animated: false, completion: nil)
    }

    deinit {
        player?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        NotificationCenter.default.removeObserver(self)
    }
}
