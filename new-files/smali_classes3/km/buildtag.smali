.class public final Lkm/buildtag;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public run()V
    .locals 4
    :try_start_0
    sget-object v0, Lni/c;->a:Lni/a;
    const/4 v1, 0x6
    const-string v2, "KMBUILD f58"
    const/4 v3, 0x0
    new-array v3, v3, [Ljava/lang/Object;
    invoke-virtual {v0, v1, v2, v3}, Lni/a;->h(ILjava/lang/String;[Ljava/lang/Object;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0
    return-void
    :catchall_0
    move-exception v0
    return-void
.end method
