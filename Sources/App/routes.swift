import Crypto
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.post("teapot") {_ in
        return HTTPResponse(status: .custom(code: 418, reasonPhrase: "I’m a teapot"))
    }
    
    let v1 = router.grouped("v1")
    
    
    // public routes
    let userController = UserController()
    v1.post("user/create",               use: userController.create)
    
    // basic / password auth protected routes
    let basic = v1.grouped(Private.User.basicAuthMiddleware(using: BCryptDigest()))
    basic.post("user/login",             use: userController.login)
    
    // bearer / token auth protected routes
    let bearer = v1.grouped(Private.User.tokenAuthMiddleware())
    
    let userRouter = bearer.grouped("user")
    userRouter.put("change/sudo",        use: userController.sudoChange)
    userRouter.put("change",        use: userController.change)
    userRouter.post("index",         use: userController.index)
    userRouter.post("list",          use: userController.list)
    
    let categoryRouter = bearer.grouped("category")
    let categoryController = CategoryController()
    categoryRouter.post("list",      use: categoryController.list)
    categoryRouter.post("create",   use: categoryController.create)
    categoryRouter.delete("delete", use: categoryController.delete)
    
    let eventRouter = bearer.grouped("event")
    let eventController = EventController()
    eventRouter.post("list",         use: eventController.list)
    eventRouter.post("index",        use: eventController.index)
    eventRouter.post("create",      use: eventController.create)
    eventRouter.put("change",       use: eventController.change)
    eventRouter.delete("delete",    use: eventController.delete)
    
    let noteRouter = bearer.grouped("note")
    let noteController = NoteController()
    noteRouter.post("list",          use: noteController.list)
    noteRouter.post("index",         use: noteController.index)
    noteRouter.post("create",       use: noteController.create)
    noteRouter.put("change",        use: noteController.change)
    noteRouter.delete("delete",     use: noteController.delete)
    
    let partRouter = bearer.grouped("part")
    let partController = PartController()
    partRouter.post("list",          use: partController.list)
    partRouter.post("index",         use: partController.index)
    partRouter.post("create",       use: partController.create)
    partRouter.put("confirm",       use: partController.confirm)
    partRouter.delete("delete",     use: partController.delete)
    
    let awardRouter = bearer.grouped("award")
    let awardController = AwardController()
   awardRouter.post("list",      use: awardController.list)
   awardRouter.post("create",   use: awardController.create)
   awardRouter.delete("delete", use: awardController.delete)
   awardRouter.post("index", use: awardController.index)
   awardRouter.put("change", use: awardController.change)
    
    let awardOfficeRouter = awardRouter.grouped("office")
    let awardOfficeController = AwardOfficeController()
    awardOfficeRouter.post("list",      use: awardOfficeController.list)
    awardOfficeRouter.post("create",   use: awardOfficeController.create)
    awardOfficeRouter.delete("delete", use: awardOfficeController.delete)
    awardOfficeRouter.post("index", use: awardOfficeController.index)
    awardOfficeRouter.put("change", use: awardOfficeController.change)
    
    
    let awardTypeRouter = awardRouter.grouped("type")
    let awardTypeController = AwardTypeController()
    awardTypeRouter.post("list",      use: awardTypeController.list)
    awardTypeRouter.post("create",   use: awardTypeController.create)
    awardTypeRouter.delete("delete", use: awardTypeController.delete)
    awardTypeRouter.post("index", use: awardTypeController.index)
    awardTypeRouter.put("change", use: awardTypeController.change)
    
    
}
