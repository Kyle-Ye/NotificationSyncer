import Testing
import NotificationSyncer
import Foundation

struct NotificitionSyncerCombinerTests {
    @Test
    func combinerExample() {
        struct LikeSyncer: NotificitionSyncer {
            struct Value: SyncableValue {
                let id: Int
                let count: Int
                
                init?(userInfo: [AnyHashable : Any]) {
                    guard let id = userInfo["id"] as? Int,
                          let count = userInfo["like_count"] as? Int else {
                        return nil
                    }
                    self.id = id
                    self.count = count
                }
                
                var userInfo: [AnyHashable : Any] {
                    ["id": id, "like_count": count]
                }
                
                init(id: Int, count: Int) {
                    self.id = id
                    self.count = count
                }
            }
            
            static var name: Notification.Name { Notification.Name("LikeChanged") }
        }
        
        struct CommentSyncer: NotificitionSyncer {
            struct Value: SyncableValue {
                let id: Int
                let count: Int
                
                init?(userInfo: [AnyHashable : Any]) {
                    guard let id = userInfo["id"] as? Int,
                          let count = userInfo["comment_count"] as? Int else {
                        return nil
                    }
                    self.id = id
                    self.count = count
                }
                
                var userInfo: [AnyHashable : Any] {
                    ["id": id, "comment_count": count]
                }
                
                init(id: Int, count: Int) {
                    self.id = id
                    self.count = count
                }
            }
            
            static var name: Notification.Name { Notification.Name("CommentChanged") }
        }
        
        typealias Syncer = NotificitionSyncerCombiner<LikeSyncer, CommentSyncer>
        
        final class RegisterCell: NotificitionSyncerDelegate {
            typealias Syncer = NotificitionSyncerCombiner<LikeSyncer, CommentSyncer>
            
            func handleSyncerNotification(_ notification: Notification) {
                defaultHandleSyncerNotification(notification)
            }
            
            let id: Int
            
            var like_count: Int = 0
            var comment_count: Int = 0
            
            init(id: Int) {
                self.id = id
                Syncer.register(self)
            }
            
            
            func syncerValueChanged(_ value: Syncer.Value) {
                if let a = value.a {
                    if a.id == id {
                        like_count = a.count
                    }
                }
                if let b = value.b {
                    if b.id == id {
                        comment_count = b.count
                    }
                }
            }
        }
        
        final class PosterCell {
            let id: Int
            var like_count: Int = 0
            var comment_count: Int = 0
            
            init(id: Int) {
                self.id = id
            }
            
            func post() {
                let value = Syncer.Value(.init(id: id, count: like_count), .init(id: id, count: comment_count))
                Syncer.post(value: value)
            }
        }
        
        let cell1 = RegisterCell(id: 1)
        let cell2 = RegisterCell(id: 2)
        let poster = PosterCell(id: 1)
        poster.like_count = 10
        poster.comment_count = 5
        poster.post()
        #expect(cell1.like_count == 10)
        #expect(cell1.comment_count == 5)
        #expect(cell2.like_count == 0)
        #expect(cell2.comment_count == 0)
    }
}
