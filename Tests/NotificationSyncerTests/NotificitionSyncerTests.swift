import Testing
import NotificationSyncer
import Foundation

struct SyncerTests {
    @Test
    func postLikeExample() {
        struct PostLikeSyncer: NotificitionSyncer {
            struct Value: SyncValueCodable {
                let postID: Int
                let count: Int
                let isLike: Bool
                
                init?(userInfo: [AnyHashable : Any]) {
                    guard let postID = userInfo["post_id"] as? Int,
                          let count = userInfo["count"] as? Int,
                          let isLike =  userInfo["is_like"] as? Bool else {
                        return nil
                    }
                    self.postID = postID
                    self.count = count
                    self.isLike = isLike
                }
                
                var userInfo: [AnyHashable : Any] {
                    ["post_id": postID, "count": count, "is_like": isLike]
                }
                
                init(postID: Int, count: Int, isLike: Bool) {
                    self.postID = postID
                    self.count = count
                    self.isLike = isLike
                }
            }
            
            static var name: Notification.Name { Notification.Name("PostLikeChanged") }
        }
        
        final class RegisterCell: NotificitionSyncerDelegate {
            func handleSyncerNotification(_ notification: Notification) {
                defaultHandleSyncerNotification(notification)
            }
            
            let id: Int
            
            var count: Int = 0
            var isLike: Bool = false
            
            init(id: Int) {
                self.id = id
                PostLikeSyncer.register(self)
            }
            
            typealias Syncer = PostLikeSyncer
            
            func syncerValueChanged(_ value: PostLikeSyncer.Value) {
                guard value.postID == id else { return }
                count = value.count
                isLike = value.isLike
            }
        }
        
        final class PosterCell {
            let id: Int

            var count: Int = 0
            var isLike: Bool = false
            
            init(id: Int) {
                self.id = id
            }
            
            func post() {
                let value = PostLikeSyncer.Value(postID: id, count: count, isLike: isLike)
                PostLikeSyncer.post(value: value)
            }
        }
        
        let cell1 = RegisterCell(id: 1)
        let cell2 = RegisterCell(id: 2)
        let poster = PosterCell(id: 1)
        poster.count = 10
        poster.isLike = true
        poster.post()
        #expect(cell1.count == 10)
        #expect(cell1.isLike == true)
        #expect(cell2.count == 0)
        #expect(cell2.isLike == false)
    }
}
