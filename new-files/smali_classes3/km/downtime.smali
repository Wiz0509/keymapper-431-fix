.class public final Lkm/downtime;
.super Ljava/lang/Object;
.field private static final a:Landroid/util/SparseLongArray;

.method static constructor <clinit>()V
    .locals 1
    new-instance v0, Landroid/util/SparseLongArray;
    invoke-direct {v0}, Landroid/util/SparseLongArray;-><init>()V
    sput-object v0, Lkm/downtime;->a:Landroid/util/SparseLongArray;
    return-void
.end method

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public static declared-synchronized put(IJ)V
    .locals 4
    sget-object v0, Lkm/downtime;->a:Landroid/util/SparseLongArray;
    invoke-virtual {v0, p0, p1, p2}, Landroid/util/SparseLongArray;->put(IJ)V
    return-void
.end method

.method public static declared-synchronized get(IJ)J
    .locals 4
    sget-object v0, Lkm/downtime;->a:Landroid/util/SparseLongArray;
    invoke-virtual {v0, p0, p1, p2}, Landroid/util/SparseLongArray;->get(IJ)J
    move-result-wide p1
    return-wide p1
.end method

.method public static declared-synchronized remove(I)V
    .locals 4
    sget-object v0, Lkm/downtime;->a:Landroid/util/SparseLongArray;
    invoke-virtual {v0, p0}, Landroid/util/SparseLongArray;->delete(I)V
    return-void
.end method
