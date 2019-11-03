import Crypto
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get("teapot") {_ in
        return HTTPResponse(status: .custom(code: 418, reasonPhrase: "I’m a teapot"))
    }
    
    let v1 = router.grouped("v1")
    
    
    // public routes
    let userController = UserController()
    v1.post("create",               use: userController.create)
    
    // basic / password auth protected routes
    let basic = v1.grouped(Private.User.basicAuthMiddleware(using: BCryptDigest()))
    basic.post("login",             use: userController.login)
    
    // bearer / token auth protected routes
    let bearer = v1.grouped(Private.User.tokenAuthMiddleware())
    bearer.put("change",            use: userController.change)
    
    let categoryRouter = bearer.grouped("category")
    let categoryController = CategoryController()
    categoryRouter.get("list",      use: categoryController.list)
    categoryRouter.post("add",      use: categoryController.create)
    categoryRouter.delete("delete", use: categoryController.delete)
    
    let eventRouter = bearer.grouped("event")
    let eventController = EventController()
    eventRouter.get("list",         use: eventController.list)
    eventRouter.get("index",        use: eventController.index)
    eventRouter.post("add",         use: eventController.create)
    eventRouter.put("change",       use: eventController.change)
    eventRouter.delete("delete",    use: eventController.delete)
    
    let noteRouter = bearer.grouped("note")
    let noteController = NoteController()
    noteRouter.get("list",          use: noteController.list)
    noteRouter.get("index",         use: noteController.index)
    noteRouter.post("add",          use: noteController.create)
    noteRouter.put("change",        use: noteController.change)
    noteRouter.delete("delete",     use: noteController.delete)
    
    let partRouter = bearer.grouped("part")
    let partController = PartController()
    partRouter.get("list",          use: partController.list)
    partRouter.get("index",         use: partController.index)
    partRouter.post("add",          use: partController.create)
    partRouter.put("confirm",       use: partController.confirm)
    partRouter.delete("delete",     use: partController.delete)
}
