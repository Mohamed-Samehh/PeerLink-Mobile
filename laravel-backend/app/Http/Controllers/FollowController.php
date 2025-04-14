<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Follow;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Storage;

class FollowController extends Controller
{
    public function toggle(Request $request, User $user)
    {
        if ($user->id === $request->user()->id) {
            return response()->json(['message' => 'Cannot follow yourself'], 422);
        }

        $follow = Follow::where('follower_id', $request->user()->id)
            ->where('followed_id', $user->id)
            ->first();

        if ($follow) {
            $follow->delete();
            return response()->json(['status' => 'unfollowed']);
        }

        Follow::create([
            'follower_id' => $request->user()->id,
            'followed_id' => $user->id,
        ]);

        return response()->json(['status' => 'followed']);
    }

    public function search(Request $request)
    {
        $search = $request->query('search', '');
        $users = User::where('username', 'like', "$search%")
            ->where('id', '!=', $request->user()->id)
            ->withCount(['followers as is_followed' => function ($query) use ($request) {
                $query->where('follower_id', $request->user()->id);
            }])
            ->orderByDesc('is_followed')
            ->orderBy('username')
            ->get()
            ->map(function ($user) {
                $user->profile_picture_url = $user->profile_picture ? Storage::url($user->profile_picture) : null;
                return $user;
            });

        return response()->json($users);
    }
}
