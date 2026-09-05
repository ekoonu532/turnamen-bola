<?php

use Illuminate\Support\Facades\Route;

// routes/web.php

Route::view('/{any}', 'welcome')->where('any', '.*');